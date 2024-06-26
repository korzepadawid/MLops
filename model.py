import os
import zipfile
import datasets
import numpy as np
import shutil

from transformers import (
    BertTokenizerFast,
    DataCollatorForTokenClassification,
    AutoModelForTokenClassification,
    TrainingArguments,
    Trainer,
)

data_archive = "./data.zip"
data_path = "./data-conll2003"
shutil.unpack_archive(data_archive, data_path, "zip")
print(f"Unzipped data {data_archive} to {data_path}")

conll2003 = datasets.load_dataset("conll2003", data_dir=data_path)
tokenizer = BertTokenizerFast.from_pretrained("bert-base-uncased")


def tokenize_and_align_labels(example, label_all_tokens=True):
    tokenized_input = tokenizer(
        example["tokens"], truncation=True, is_split_into_words=True
    )
    labels = []
    for i, label in enumerate(example["ner_tags"]):
        word_ids = tokenized_input.word_ids(batch_index=i)

        prev_word_idx = None
        label_ids = []
        for word_idx in word_ids:
            if word_idx is None:
                label_ids.append(-100)  # pytorch will ignore if -100
            elif word_idx != prev_word_idx:
                label_ids.append(label[word_idx])
            else:
                label_ids.append(label[word_idx] if label_all_tokens else -100)
            prev_word_idx = word_idx
        labels.append(label_ids)
    tokenized_input["labels"] = labels
    return tokenized_input


g = tokenize_and_align_labels(conll2003["train"][4:5])
print(g)

for token, label in zip(
    tokenizer.convert_ids_to_tokens(g["input_ids"][0]), g["labels"][0]
):
    print(f"{token:_<40} {label}")

tokenized_dataset = conll2003.map(tokenize_and_align_labels, batched=True)

model = AutoModelForTokenClassification.from_pretrained(
    "bert-base-uncased", num_labels=9
)  # must match

data_collator = DataCollatorForTokenClassification(tokenizer)

metric = datasets.load_metric("seqeval")

label_list = conll2003["train"].features["ner_tags"].feature.names

label_list

example_text = conll2003["train"][0]

labels = [label_list[i] for i in example_text["ner_tags"]]

metric.compute(predictions=[labels], references=[labels])


def compute_metrics(eval_preds):
    """
    Function to compute the evaluation metrics for Named Entity Recognition (NER) tasks.
    The function computes precision, recall, F1 score and accuracy.

    Parameters:
    eval_preds (tuple): A tuple containing the predicted logits and the true labels.

    Returns:
    A dictionary containing the precision, recall, F1 score and accuracy.
    """
    pred_logits, labels = eval_preds

    pred_logits = np.argmax(pred_logits, axis=2)
    # the logits and the probabilities are in the same order,
    # so we don’t need to apply the softmax

    # We remove all the values where the label is -100
    predictions = [
        [
            label_list[eval_preds]
            for (eval_preds, l) in zip(prediction, label)
            if l != -100
        ]
        for prediction, label in zip(pred_logits, labels)
    ]

    true_labels = [
        [label_list[l] for (eval_preds, l) in zip(prediction, label) if l != -100]
        for prediction, label in zip(pred_logits, labels)
    ]
    results = metric.compute(predictions=predictions, references=true_labels)
    return {
        "precision": results["overall_precision"],
        "recall": results["overall_recall"],
        "f1": results["overall_f1"],
        "accuracy": results["overall_accuracy"],
    }


args = TrainingArguments(
    "test-ner",
    evaluation_strategy="epoch",
    learning_rate=2e-5,
    per_device_train_batch_size=16,
    per_device_eval_batch_size=16,
    num_train_epochs=3,
    weight_decay=0.01,
)

trainer = Trainer(
    model,
    args,
    train_dataset=tokenized_dataset["train"],
    eval_dataset=tokenized_dataset["validation"],
    data_collator=data_collator,
    tokenizer=tokenizer,
    compute_metrics=compute_metrics,
)

data_collator = DataCollatorForTokenClassification(tokenizer)

metric = datasets.load_metric("seqeval")

trainer.train()

model.save_pretrained("ner_model")

tokenizer.save_pretrained("tokenizer")


def zip_directory(directory_path, zip_path):
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, _, files in os.walk(directory_path):
            for file in files:
                file_path = os.path.join(root, file)
                zipf.write(file_path, os.path.relpath(file_path, directory_path))


ner_path = "ner_model.zip"
zip_directory("ner_model", ner_path)
print(f"Model successfully saved to {ner_path}")

tokenizer_path = "tokenizer.zip"
zip_directory("tokenizer", tokenizer_path)
print(f"Tokenuizer successfully saved to {tokenizer_path}")

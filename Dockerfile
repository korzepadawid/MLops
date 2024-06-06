FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libopenblas-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/* 

RUN useradd -ms /bin/bash appuser && \
    mkdir -p /home/appuser/.cache/huggingface && \
    chown -R appuser:appuser /home/appuser/.cache

WORKDIR /home/appuser/app

USER appuser

ENV PATH=$PATH:/home/appuser/.local/bin

ENV TRANSFORMERS_CACHE=/home/appuser/.cache/huggingface

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade -r requirements.txt

RUN pip list

COPY model.py .

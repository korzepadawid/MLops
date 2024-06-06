FROM python:3.12-slim

# Set environment variables to prevent Python from writing pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libopenblas-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/* 

# Create a non-root user and set permissions
RUN useradd -ms /bin/bash appuser && \
    mkdir -p /home/appuser/.cache/huggingface && \
    chown -R appuser:appuser /home/appuser/.cache

# Set the working directory
WORKDIR /app

# Switch to non-root user
USER appuser

# Copy requirements.txt and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Copy the rest of the application code
COPY model.py .

# Set the environment variable for the Hugging Face cache directory
ENV TRANSFORMERS_CACHE=/home/appuser/.cache/huggingface

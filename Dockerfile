FROM python:3.12-slim

# Set environment variables to prevent Python from writing pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the cache directory for HF, to avoid jenkins issues
ENV TRANSFORMERS_CACHE=./cache/

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libopenblas-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY model.py .
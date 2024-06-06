FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libopenblas-dev \
    sudo \ 
    python3-pip \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /app

COPY requirements.txt .

COPY model.py .

RUN python3 -m venv .venv
RUN /app/.venv/bin/pip install -r requirements.txt
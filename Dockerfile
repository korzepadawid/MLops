FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libopenblas-dev \
    sudo \ 
    python3-pip \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY model.py .

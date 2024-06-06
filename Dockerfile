FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libopenblas-dev \
    sudo \ 
    python3-pip \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /app

COPY requirements.txt .

COPY model.py .

RUN python3 -m venv .venv
RUN source .venv/bin/activate
RUN python3 -m pip install -r requirements.txt
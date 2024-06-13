FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libopenblas-dev \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /app

COPY requirements.txt .

COPY model.py .

RUN chmod 777 model.py

ENTRYPOINT ["/bin/sh"]
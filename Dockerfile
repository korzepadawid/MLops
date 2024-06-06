FROM python:3.12-slim

RUN useradd -m -u 1000 user
USER user

# Set environment variables to prevent Python from writing pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV HOME=/home/user \
	PATH=/home/user/.local/bin:$PATH

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libopenblas-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /app

COPY requirements.txt .

RUN chown -R user:user /code

RUN pip install --no-cache-dir --upgrade -r requirements.txt

COPY model.py .
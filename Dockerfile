# FROM python:3.11-slim

# ENV PYTHONDONTWRITEBYTECODE=1
# ENV PYTHONUNBUFFERED=1

# WORKDIR /app

# RUN apt-get update && apt-get install -y \
#     build-essential \
#     default-libmysqlclient-dev \
#     libpq-dev \
#     libssl-dev \
#     libffi-dev \
#     pkg-config \
#     curl \
#     gcc \
#     libjpeg-dev \
#     zlib1g-dev \
#     libpng-dev \
#     libtiff-dev \
#     libgl1 \
#     libxml2-dev \
#     libxslt1-dev \
#     libatlas-base-dev \
#     liblapack-dev \
#     gfortran \
#     git \
#     && rm -rf /var/lib/apt/lists/*

# COPY requirements.txt .
# RUN pip install --upgrade pip && pip install -r requirements.txt

# COPY . .

# EXPOSE 5000

# CMD ["python", "main.py"]
# Use official Python slim image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install dependencies required for psycopg2 and other common packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirement files first (for caching layer)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip \
    && pip install gunicorn \
    && pip install -r requirements.txt

# Copy project files
COPY . .

# Expose the port Flask/Gunicorn will run on
EXPOSE 5000

# Start using Gunicorn with 4 workers (tweak based on instance size)
CMD ["gunicorn", "--workers=4", "--bind=0.0.0.0:5000", "main:app"]

# Hugging Face Spaces requires port 7860
# We use a slim Python image to keep the container small
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system-level dependencies required by OpenCV and EasyOCR
RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies first (Docker layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY main.py .

# Hugging Face Spaces exposes port 7860 by default
EXPOSE 7860

# Start the FastAPI server on port 7860
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]

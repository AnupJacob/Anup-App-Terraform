# Use official Python image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY ../requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY .. .

# Expose port the app runs on
EXPOSE 5000

# Default command to run the app
CMD ["python", "app.py"]

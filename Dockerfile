# Use Python 3.11 image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements if you have one
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app folder into container
COPY app/ .

# Expose port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]


# Use a lightweight Python base image
FROM python:3.12-slim

# Create non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Set working directory
WORKDIR /app

# Copy files
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 5000

# Run app
CMD ["python", "app.py"]

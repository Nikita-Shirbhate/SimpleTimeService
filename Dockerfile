# Dockerfile for SimpleTimeService

# Start with a lightweight official Python image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file to the container
COPY app/requirements.txt .

# Install dependencies using pip (no cache to keep image small)
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY app/ .

# Create a non-root user named 'appuser' and give ownership of the /app directory
RUN useradd -m appuser && chown -R appuser /app

# Switch to the non-root user
USER appuser

# Expose port 5000 so the container can listen on it at runtime
EXPOSE 5000

# Command to run the application using Gunicorn WSGI server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]
# Note: The application is expected to be served on port 5000 inside the container.

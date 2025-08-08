# Stage 1: Build the application
FROM python:3.8-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y libxml2-dev libxslt-dev build-essential zlib1g-dev

# Install dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt


# Stage 2: Create the production image
FROM python:3.8-slim

WORKDIR /app

# Create a non-root user
RUN useradd --create-home appuser

# Copy installed dependencies from builder stage
COPY --from=builder /wheels /wheels
RUN pip install --no-cache /wheels/*

# Copy the application code
COPY . .

# Create the configuration directory and copy configs
RUN mkdir -p /etc/serles /etc/serles/data
COPY gunicorn_config.py /etc/serles/gunicorn_config.py

# Switch to the non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 8000

# Run the application
CMD ["gunicorn", "--config", "/etc/serles/gunicorn_config.py", "serles:create_app()"]

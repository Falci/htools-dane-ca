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

# Copy installed dependencies from builder stage
RUN useradd --create-home appuser

# Copy installed dependencies from builder stage
COPY --from=builder /wheels /wheels
RUN pip install --no-cache /wheels/*

# Copy the application code
COPY . .

# Create the configuration directory and copy configs
RUN mkdir -p /etc/serles /etc/serles/data
COPY gunicorn_config.py /etc/serles/gunicorn_config.py

# Copy entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose the port the app runs on
EXPOSE 8000

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []

USER appuser

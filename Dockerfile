# ----------------------------------------------------
# Stage 1 — Build stage (dependency installation)
# ----------------------------------------------------
FROM python:3.12-slim AS builder 
#Removes build tools from runtime image 

# Prevent Python from writing .pyc files
ENV PYTHONDONTWRITEBYTECODE=1
# Ensure logs are flushed immediately
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies only if required
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements first (Docker layer caching optimization)
COPY requirements.txt .

# Upgrade pip safely and install dependencies
RUN pip install --upgrade pip \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt


# ----------------------------------------------------
# Stage 2 — Runtime stage (minimal image)
# ----------------------------------------------------
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create non-root user (security best practice)
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Copy installed packages from builder stage
COPY --from=builder /install /usr/local

# Copy application code
COPY . .

# Set proper ownership
RUN chown -R appuser:appgroup /app

USER appuser

# Expose application port
EXPOSE 5000

# Healthcheck (used by Kubernetes / Docker)
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1

# Use production-grade WSGI server instead of Flask dev server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
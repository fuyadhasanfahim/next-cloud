# syntax=docker/dockerfile:1
FROM nextcloud:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        imagemagick \
    && rm -rf /var/lib/apt/lists/*
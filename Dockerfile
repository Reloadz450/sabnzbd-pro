# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-alpine:3.21

ARG BUILD_DATE
ARG VERSION
ARG SABNZBD_VERSION=4.2.2

LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Reloadz450"

ENV HOME="/config" \
    PYTHONIOENCODING=utf-8

# Install dependencies
RUN apk add --no-cache \
    python3 py3-pip py3-virtualenv \
    ffmpeg pigz unzip unrar tar par2cmdline bash jq curl

# Install SABnzbd
RUN mkdir -p /app/sabnzbd && \
    curl -L "https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz" -o /tmp/sabnzbd.tar.gz && \
    tar -xf /tmp/sabnzbd.tar.gz -C /app/sabnzbd --strip-components=1 && \
    rm -f /tmp/sabnzbd.tar.gz

# Set up Python virtual environment
RUN python3 -m venv /lossy && \
    /lossy/bin/python -m pip install --upgrade pip setuptools wheel && \
    /lossy/bin/pip install --no-cache-dir -r /app/sabnzbd/requirements.txt

# Dummy postproc script for validation
RUN echo -e '#!/bin/sh\nexit 0' > /usr/local/bin/postproc_verify_ffprobe.sh && \
    chmod +x /usr/local/bin/postproc_verify_ffprobe.sh

# Fix for par2 binary missing
RUN ln -s /usr/bin/par2 /usr/local/bin/par2

# Copy static unrar binary
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# Final container config
EXPOSE 8080 8090
VOLUME /config

ENTRYPOINT ["/lossy/bin/python3"]
CMD ["/app/sabnzbd/SABnzbd.py", "--server", "0.0.0.0:8080", "--config-file", "/config"]

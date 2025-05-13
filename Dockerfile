# syntax=docker/dockerfile:1

FROM ubuntu:22.04

ARG BUILD_DATE
ARG VERSION
ARG SABNZBD_VERSION=4.2.2

LABEL build_version="Reloadz450 version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Reloadz450"

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME="/config"
ENV PYTHONIOENCODING=utf-8

# Install required packages
RUN apt-get update && \
    apt-get install -y \
    python3 python3-pip python3-venv \
    ffmpeg pigz unzip unrar tar par2 jq curl bash && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install SABnzbd
RUN mkdir -p /app/sabnzbd && \
    curl -L "https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz" -o /tmp/sabnzbd.tar.gz && \
    tar -xf /tmp/sabnzbd.tar.gz -C /app/sabnzbd --strip-components=1 && \
    rm -f /tmp/sabnzbd.tar.gz

# Set up Python venv and install dependencies
RUN python3 -m venv /lossy && \
    /lossy/bin/python -m pip install --upgrade pip setuptools wheel && \
    /lossy/bin/pip install --no-cache-dir -r /app/sabnzbd/requirements.txt

# Dummy script for postproc to avoid SAB errors
RUN echo -e '#!/bin/bash\nexit 0' > /usr/local/bin/postproc_verify_ffprobe.sh && \
    chmod +x /usr/local/bin/postproc_verify_ffprobe.sh

# Define mount point and ports
VOLUME /config
EXPOSE 8080 8090

ENTRYPOINT ["/lossy/bin/python3"]
CMD ["/app/sabnzbd/SABnzbd.py", "--server", "0.0.0.0:8080", "--config-file", "/config"]

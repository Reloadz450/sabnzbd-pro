# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ubuntu:22.04

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SABNZBD_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Reloadz450 <github.com/Reloadz450>"

ENV HOME="/config" \
    PYTHONIOENCODING=utf-8 \
    DEBIAN_FRONTEND=noninteractive

# install system deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        curl \
        jq \
        ffmpeg \
        pigz \
        unzip \
        unrar \
        tar \
        par2 \
        bash \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# download and install sabnzbd
RUN SABNZBD_VERSION=$(curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest | jq -r '.tag_name') && \
    mkdir -p /app/sabnzbd && \
    curl -L "https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz" \
         -o /tmp/sabnzbd.tar.gz && \
    tar -xf /tmp/sabnzbd.tar.gz -C /app/sabnzbd --strip-components=1 && \
    rm -f /tmp/sabnzbd.tar.gz

# create virtualenv and install dependencies
RUN python3 -m venv /lossy && \
    /lossy/bin/pip install --upgrade pip && \
    /lossy/bin/pip install --no-cache-dir -r /app/sabnzbd/requirements.txt

# add post-processing script
COPY root/etc/scripts/postproc_verify_ffprobe.sh /usr/local/bin/postproc_verify_ffprobe.sh
RUN chmod +x /usr/local/bin/postproc_verify_ffprobe.sh

# add local files
COPY root/ /

# add unrar from alpine base
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

EXPOSE 8080
VOLUME /config

# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-alpine:3.21

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SABNZBD_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ENV HOME="/config" \
    PYTHONIOENCODING=utf-8

# install all required packages and sabnzbd
RUN apk add --update --no-cache \
        ffmpeg \
        pigz \
        unzip \
        unrar \
        tar \
        par2cmdline \
        bash \
        jq \
        python3 \
        py3-pip \
        py3-virtualenv && \
    echo "***** installing sabnzbd *****" && \
    sh -c '\
        SABNZBD_VERSION="${SABNZBD_VERSION:-$(curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest | jq -r ".tag_name")}" && \
        mkdir -p /app/sabnzbd && \
        curl -L "https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz" -o /tmp/sabnzbd.tar.gz && \
        tar -xf /tmp/sabnzbd.tar.gz -C /app/sabnzbd --strip-components=1 && \
        rm -f /tmp/sabnzbd.tar.gz && \
        python3 -m venv /lossy && \
        /lossy/bin/pip install -U --no-cache-dir pip && \
        /lossy/bin/pip install -U --no-cache-dir -r /app/sabnzbd/requirements.txt \
    ' && \
    echo "***** cleanup *****" && \
    apk del --no-network --purge \
        build-base \
        autoconf \
        libffi-dev \
        libxml2-dev \
        libxslt-dev && \
    rm -rf /tmp/* /var/cache/apk/*

# Add post-processing script
COPY root/etc/scripts/postproc_verify_ffprobe.sh /usr/local/bin/postproc_verify_ffprobe.sh
RUN chmod +x /usr/local/bin/postproc_verify_ffprobe.sh

# add local files
COPY root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 8080
VOLUME /config

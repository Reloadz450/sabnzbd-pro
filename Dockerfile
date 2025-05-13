# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-alpine:3.21

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SABNZBD_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Reloadz450"

ENV HOME="/config" \
    PYTHONIOENCODING=utf-8

# install packages and sabnzbd in one consistent shell block
RUN sh -c ' \
  apk add --no-cache \
    python3 py3-pip py3-virtualenv \
    ffmpeg pigz unzip unrar tar par2cmdline bash jq curl && \
  SABNZBD_VERSION=$(curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest | jq -r ".tag_name") && \
  mkdir -p /app/sabnzbd && \
  curl -L "https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz" -o /tmp/sabnzbd.tar.gz && \
  tar -xf /tmp/sabnzbd.tar.gz -C /app/sabnzbd --strip-components=1 && \
  rm -f /tmp/sabnzbd.tar.gz && \
  python3 -m venv /lossy && \
  /lossy/bin/python -m pip install --upgrade pip setuptools wheel && \
  /lossy/bin/pip install --no-cache-dir -r /app/sabnzbd/requirements.txt \
'
# copy post-processing script
COPY root/etc/scripts/postproc_verify_ffprobe.sh /usr/local/bin/postproc_verify_ffprobe.sh
RUN chmod +x /usr/local/bin/postproc_verify_ffprobe.sh

# add local files
COPY root/ /

# add static unrar binary
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# expose ports
EXPOSE 8080 8090
VOLUME /config

# start sabnzbd
ENTRYPOINT ["/lossy/bin/python3", "/app/sabnzbd/SABnzbd.py"]
CMD ["--server", "0.0.0.0:8080", "--config-file", "/config"]






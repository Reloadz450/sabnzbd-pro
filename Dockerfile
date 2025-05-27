FROM python:3.12-slim

LABEL maintainer="Reloadz450"
LABEL version="4.5.1"
LABEL description="Custom SABnzbd-Pro build with upstream SABnzbd 4.5.1, parallel unpack, ffprobe validation, and optimized post-processing support."

RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    p7zip-full \
    par2 \
    unrar-free \
    ca-certificates \
    curl \
    tzdata \
    logrotate && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/sabnzbd
RUN git clone https://github.com/sabnzbd/sabnzbd.git . && \
    git checkout tags/4.5.1 && \
    pip install --no-cache-dir -r requirements.txt

COPY scripts/ /opt/sabnzbd/scripts/
RUN chmod +x /opt/sabnzbd/scripts/*.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

COPY logrotate-launch.sh /usr/local/bin/logrotate-launch.sh
RUN chmod +x /usr/local/bin/logrotate-launch.sh

RUN mkdir -p /config /downloads/complete /downloads/incomplete /downloads/intermediate /scripts

VOLUME /config
VOLUME /downloads
VOLUME /scripts

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s CMD ["/usr/local/bin/healthcheck.sh"]

ENV LOGROTATE_VERBOSE=true

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
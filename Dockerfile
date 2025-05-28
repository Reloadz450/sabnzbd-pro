# syntax=docker/dockerfile:1.4

FROM python:3.12-slim AS base

LABEL maintainer="Reloadz450"
LABEL version="4.5.1"
LABEL description="SABnzbd Pro 4.5.1 with par2cmdline-turbo, full post-processing stack, and optimized runtime."

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin"

WORKDIR /opt/sabnzbd

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git gcc g++ make unzip \
        par2 ffmpeg p7zip-full \
        autoconf automake libtool \
        pkg-config logrotate curl wget \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install unrar v7.11 from rarlab
RUN curl -fsSL https://www.rarlab.com/rar/rarlinux-x64-711.tar.gz -o /tmp/rar.tar.gz && \
    tar -xzf /tmp/rar.tar.gz -C /tmp && \
    cp /tmp/rar/unrar /usr/local/bin/unrar && \
    chmod +x /usr/local/bin/unrar && \
    rm -rf /tmp/rar*

# Install par2cmdline-turbo v1.3.0
COPY root/par2cmdline-turbo-v1.3.0.tar.gz /tmp/
RUN tar -xf /tmp/par2cmdline-turbo-v1.3.0.tar.gz -C /tmp && \
    cd /tmp/par2cmdline-turbo-1.3.0 && \
    ./automake.sh && ./configure && \
    make -j$(nproc) && make install && \
    cd / && rm -rf /tmp/par2cmdline-turbo*

# Clone SABnzbd and install requirements
RUN git clone -b 4.5.1 https://github.com/sabnzbd/sabnzbd.git /opt/sabnzbd
WORKDIR /opt/sabnzbd

RUN pip install --upgrade pip setuptools wheel cython && \
    pip install -r requirements.txt

# Copy entrypoint and helper scripts
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
COPY logrotate-launch.sh /usr/local/bin/logrotate-launch.sh
COPY scripts/ /config/scripts/

# Sanity check
RUN test -x /usr/local/bin/entrypoint.sh || (echo "ERROR: entrypoint.sh missing or not executable!" && exit 1)

# Permissions
RUN chmod +x /usr/local/bin/*.sh && chmod +x /config/scripts/*.sh

# Create expected directories
RUN mkdir -p /etc/logrotate.d /config/logs

# Expose SABnzbd ports and define mount points
EXPOSE 8080 8090
VOLUME ["/config", "/downloads", "/incomplete"]

ENV LOGROTATE_VERBOSE=false

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

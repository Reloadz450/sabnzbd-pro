# Dockerfile for SABnzbd-Pro with par2cmdline-turbo and all dependencies

FROM python:3.12-slim AS base

LABEL maintainer="Reloadz450"
LABEL version="4.5.1"
LABEL description="Feature-rich SABnzbd build with enhanced unpacking, validation, and post-processing support."

ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /opt/sabnzbd

# Install system dependencies
# Install official RARLabs unrar from tar.gz
RUN curl -fsSL https://www.rarlab.com/rar/rarlinux-x64-711.tar.gz -o /tmp/rar.tar.gz && \
    cd /tmp && \
    tar -xzf rar.tar.gz && \
    cp rar/unrar /usr/local/bin/unrar && \
    chmod +x /usr/local/bin/unrar && \
    rm -rf /tmp/rar*

RUN apt-get update && \
    apt-get install -y \
#        unrar-free \
        git \
        gcc \
        g++ \
        make \
        unzip \
        par2 \
        ffmpeg \
        p7zip-full \
        autoconf \
        automake \
        libtool \
        pkg-config \
        logrotate \
        curl \
        wget && \
    rm -rf /var/lib/apt/lists/*

# Install par2cmdline-turbo v1.3.0 from source
COPY root/par2cmdline-turbo-v1.3.0.tar.gz /tmp/
RUN cd /tmp && \
    tar -xf par2cmdline-turbo-v1.3.0.tar.gz && \
    cd par2cmdline-turbo-1.3.0 && \
    ./automake.sh && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/par2cmdline-turbo*

# Clone SABnzbd and install Python requirements
RUN git clone -b 4.5.1 https://github.com/sabnzbd/sabnzbd.git /opt/sabnzbd
WORKDIR /opt/sabnzbd
RUN pip install --upgrade \
        pip==25.1.1 \
        setuptools==80.9.0 \
        wheel==0.45.1 \
        cython==3.1.1 && \
    pip install -r requirements.txt

# Copy entrypoint scripts and support files
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
COPY logrotate-launch.sh /usr/local/bin/logrotate-launch.sh
COPY scripts/ /config/scripts/

RUN chmod +x /usr/local/bin/*.sh && chmod +x /config/scripts/*.sh

# Add logrotate config path
RUN mkdir -p /etc/logrotate.d /config/logs

# Ports and volumes
EXPOSE 8080
VOLUME ["/config", "/downloads", "/incomplete"]

# Environment for logrotate verbosity (optional)
ENV LOGROTATE_VERBOSE=false

# Healthcheck
HEALTHCHECK CMD ["healthcheck.sh"]

# Entrypoint
ENTRYPOINT ["entrypoint.sh"]

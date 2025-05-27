# SABnzbd-Pro (Upstream v4.5.1 with par2cmdline-turbo)

![Docker Pulls](https://img.shields.io/docker/pulls/r00str/sabnzbd-pro)
![Docker Image Version](https://img.shields.io/badge/version-4.5.1-blue)

A high-performance SABnzbd container fork built from upstream v4.5.1, enhanced with:
- ✅ Full post-processing support (parallel unpacking, par2 repair, ffprobe validation)
- ✅ Native log rotation with verbose logging and rotation policies
- ✅ `par2cmdline-turbo` v1.3.0 installed and enabled
- ✅ Health checks, clean entrypoint, and config volume preservation

---

## 🚀 Quickstart (Docker CLI)
```bash
docker run -d \
  --name sabnzbd-pro \
  -p 8080:8080 \
  -v /mnt/user/appdata/sabnzbd-pro/config:/config \
  -v /mnt/user/downloads:/downloads \
  -v /mnt/user/appdata/sabnzbd-pro/scripts:/scripts \
  -e LOGROTATE_VERBOSE=true \
  r00str/sabnzbd-pro:latest
```

## 🔧 Environment Variables
| Variable            | Default | Description                         |
|---------------------|---------|-------------------------------------|
| `LOGROTATE_VERBOSE` | `true`  | Enable verbose output to log files  |

---

## 🛠 Sample docker-compose.yml
```yaml
version: '3.8'
services:
  sabnzbd:
    container_name: sabnzbd-pro
    image: r00str/sabnzbd-pro:latest
    ports:
      - 8080:8080
    volumes:
      - ./config:/config
      - ./downloads:/downloads
      - ./scripts:/scripts
    environment:
      - LOGROTATE_VERBOSE=true
    healthcheck:
      test: ["CMD", "/usr/local/bin/healthcheck.sh"]
      interval: 30s
      timeout: 10s
      retries: 3
```

---

## 📂 Volumes
- `/config`: Application config, logs, and `sabnzbd.ini`
- `/downloads`: Complete, incomplete, intermediate content directories
- `/scripts`: Post-processing scripts (e.g. `parallel_unpack_and_repair.sh`)

---

## 🔍 What's Installed?
- **SABnzbd** 4.5.1 (from upstream GitHub)
- **par2cmdline-turbo** 1.3.0 — optimized, multithreaded PAR2 utility
- `ffmpeg`, `7z`, `unrar-free`, `logrotate`, `curl`, `git`, and required system libs

---

## 🧪 Verify par2cmdline-turbo
Inside the container:
```bash
docker exec -it sabnzbd-pro par2 --version
```
Or view detection status in WebUI under:
```
Config → General → External Programs
```

---

## ✅ Tags
- `latest` → Tracks main branch builds
- `4.5.1` → Locked to SABnzbd upstream release v4.5.1

---

## 🤝 Maintainer
Built and maintained by [Reloadz450](https://github.com/Reloadz450). Based on upstream [sabnzbd/sabnzbd](https://github.com/sabnzbd/sabnzbd).

PRs, feature requests, and suggestions are welcome.

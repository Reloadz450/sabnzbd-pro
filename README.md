# r00str/sabnzbd-pro

Custom SABnzbd Docker container with enhanced post-processing, ffprobe validation, and direct unpack support for optimized media automation workflows.

![Docker Pulls](https://img.shields.io/docker/pulls/r00str/sabnzbd-pro)
![Last Commit](https://img.shields.io/github/last-commit/Reloadz450/sabnzbd-pro)

---

## 🔧 Features

- Latest SABnzbd release from source
- Built-in Python virtual environment (`/lossy`)
- Post-processing validation using `ffprobe`
- Docker-compatible multi-arch support (x86_64, aarch64)
- Designed for seamless integration with Sonarr, Radarr, Lidarr, etc.

---

## 📁 Volumes

| Container Path        | Purpose                            |
|-----------------------|-------------------------------------|
| `/config`             | SABnzbd config                     |
| `/mnt/etb/downloads`  | Downloads (completed/incomplete)   |
| `/mnt/user/mmc`       | Optional scratch space             |
| `/mnt/cache/appdata/openssl` | SSL certs (optional)      |

---

## 🌐 Ports

| Port   | Description   |
|--------|---------------|
| 8080   | Web UI        |
| 8090   | API/alt port  |

---

## 🌍 Environment Variables

| Variable     | Default | Description                        |
|--------------|---------|------------------------------------|
| `PUID`       | 99      | User ID for permissions            |
| `PGID`       | 100     | Group ID for permissions           |
| `UMASK`      | 000     | File creation mask                 |
| `TZ`         | UTC     | Timezone (e.g. America/Chicago)    |

---

## 📜 Source

- [GitHub Repo](https://github.com/Reloadz450/sabnzbd-pro)
- [Docker Hub](https://hub.docker.com/r/r00str/sabnzbd-pro)
- [SABnzbd](https://sabnzbd.org/)

---

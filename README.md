# ☁️ Nextcloud Self-Hosted Setup

A self-hosted Google Drive + Google Photos alternative using **Nextcloud**, **MariaDB**, **Redis**, and **Cloudflare Tunnel** — no open ports required.

---

## 📁 Project Structure

```
nextcloud/
├── docker-compose.yml   # All services defined here
├── Dockerfile           # Custom Nextcloud image with ffmpeg
├── .env                 # Secrets & config (never commit this!)
├── .gitignore           # Ignores .env
└── .gitattributes       # Forces LF line endings (cross-platform)
```

---

## ⚙️ Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Docker Desktop | Latest | Windows: must use **Linux containers** mode |
| WSL2 (Windows) | Latest | Recommended for better performance |
| Cloudflare account | — | Free tier works |
| Domain name | — | e.g. `cloud.yourdomain.com` |

---

## 🚀 First-Time Setup

### 1. Clone or create the project folder

```bash
mkdir nextcloud && cd nextcloud
```

### 2. Create all required files

Copy the `docker-compose.yml`, `Dockerfile`, `.env`, `.gitattributes` into the folder.

### 3. Edit the `.env` file

```env
# Database
MYSQL_ROOT_PASSWORD=your_strong_password
MYSQL_PASSWORD=your_strong_password
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud

# Nextcloud URL
NEXTCLOUD_URL=https://cloud.yourdomain.com
NEXTCLOUD_HOST=cloud.yourdomain.com

# Cloudflare Tunnel token (from Cloudflare dashboard)
TUNNEL_TOKEN=your_tunnel_token_here
```

> ⚠️ **Never commit `.env` to Git.** It contains your passwords and tunnel token.

### 4. Set up Cloudflare Tunnel

1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com)
2. Navigate to **Networks → Tunnels → Create a tunnel**
3. Choose **Cloudflared** → name your tunnel
4. Copy the tunnel token → paste into `.env` as `TUNNEL_TOKEN`
5. Add a **Public Hostname**:
   - Subdomain: `cloud`
   - Domain: `yourdomain.com`
   - Service: `http://app:80`

### 5. Build and start

```bash
# Build custom image and start all containers
docker compose up -d --build

# Check all containers are running
docker compose ps

# Watch logs
docker compose logs -f app
```

### 6. Complete Nextcloud web setup

Open `https://cloud.yourdomain.com` in your browser and:

1. Create an admin username and password
2. Database settings should auto-fill (they come from `.env`)
3. Click **Install recommended apps** or skip for now

---

## 🐳 Services Overview

| Service | Image | Purpose |
|---------|-------|---------|
| `app` | Custom (Nextcloud + ffmpeg) | Main Nextcloud application |
| `db` | `mariadb:10.6` | Database |
| `redis` | `redis:alpine` | File locking & caching |
| `cloudflared` | `cloudflare/cloudflared` | Secure tunnel (no open ports) |

---

## 📸 Google Photos Alternative (Nextcloud Memories)

The custom Dockerfile installs `ffmpeg` and `imagemagick` which are required for the **Memories** app.

### Install Memories app

1. Go to **Apps** in Nextcloud (top-right menu)
2. Search for **Memories**
3. Click **Download and enable**
4. Go to **Settings → Memories** and run the initial index

### Features you get
- Timeline view like Google Photos
- Face recognition
- Video transcoding
- Map view

---

## 🔄 Common Commands

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# Restart a single service
docker compose restart app

# View logs
docker compose logs -f          # all services
docker compose logs -f app      # only Nextcloud
docker compose logs -f db       # only database

# Rebuild after Dockerfile changes
docker compose build --no-cache app
docker compose up -d

# Run Nextcloud CLI commands (occ)
docker compose exec app php occ <command>

# Example: scan files
docker compose exec app php occ files:scan --all

# Example: check system status
docker compose exec app php occ status
```

---

## 🔧 Troubleshooting

### Container won't start

```bash
docker compose ps          # check status
docker compose logs app    # check error messages
```

### Database connection error

```bash
# Check if DB is healthy
docker compose ps db

# Check DB logs
docker compose logs db
```

### Nextcloud shows maintenance mode

```bash
docker compose exec app php occ maintenance:mode --off
```

### Cloudflare tunnel not connecting

```bash
docker compose logs cloudflared
```

Make sure the `TUNNEL_TOKEN` in `.env` is correct and matches the Cloudflare dashboard.

### Files not showing up

```bash
docker compose exec app php occ files:scan --all
```

### Build fails — package not found

```bash
# Check what packages are available in the container
docker run --rm nextcloud:latest apt-cache search magick
docker run --rm nextcloud:latest apt-cache search ffmpeg
```

---

## 💾 Backup

### Backup volumes

```bash
# Backup Nextcloud files
docker run --rm \
  -v next-cloud_nextcloud_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/nextcloud_backup.tar.gz /data

# Backup database
docker compose exec db mysqldump \
  -u nextcloud -p nextcloud > backup.sql
```

### Restore database

```bash
cat backup.sql | docker compose exec -T db mysql \
  -u nextcloud -p nextcloud
```

---

## 🔐 Security Notes

- `.env` is excluded from Git via `.gitignore` — keep it safe
- Cloudflare Tunnel means **no ports are exposed** to the internet
- Nextcloud is only accessible through your Cloudflare domain
- Rotate your `TUNNEL_TOKEN` from the Cloudflare dashboard if it gets leaked
- Use a **strong, unique password** for `MYSQL_ROOT_PASSWORD` and `MYSQL_PASSWORD`

---

## 🪟 Windows-Specific Notes

- Docker Desktop must be in **Linux containers** mode (default)
- Use **WSL2** backend for better performance (Docker Desktop → Settings → General)
- All config files must use **LF** line endings, not CRLF
  - VSCode: click `CRLF` in the bottom-right status bar → change to `LF`
  - The `.gitattributes` file handles this automatically on Git checkout

---

## 📦 Updating Nextcloud

```bash
# Pull latest images
docker compose pull

# Rebuild and restart
docker compose up -d --build

# Run upgrade (if needed)
docker compose exec app php occ upgrade
```

---

## 🗂️ Environment Variables Reference

| Variable | Description |
|----------|-------------|
| `MYSQL_ROOT_PASSWORD` | MariaDB root password |
| `MYSQL_PASSWORD` | Nextcloud DB user password |
| `MYSQL_DATABASE` | Database name (default: `nextcloud`) |
| `MYSQL_USER` | Database username (default: `nextcloud`) |
| `NEXTCLOUD_URL` | Full URL with `https://` |
| `NEXTCLOUD_HOST` | Hostname only (no `https://`) |
| `TUNNEL_TOKEN` | Cloudflare tunnel token |
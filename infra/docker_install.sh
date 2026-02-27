#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*"
}

log "Updating package index"
apt-get update

log "Upgrading installed packages"
apt-get upgrade -y

log "Installing prerequisites"
apt-get install -y ca-certificates curl

log "Creating keyrings directory"
install -m 0755 -d /etc/apt/keyrings

log "Adding Docker GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

log "Adding Docker apt repository"
tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

log "Updating package index (Docker repo)"
apt-get update

log "Installing Docker Engine"
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log "Docker installation complete"

#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*"
}

log "Updating package index"
apt-get update

log "Upgrading installed packages"
apt-get upgrade -y

log "Installing Nginx"
apt-get install -y nginx

log "Starting Nginx"
systemctl start nginx

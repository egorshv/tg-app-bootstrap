#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*"
}

log "Enabling Firewall"
ufw enable

log "Allowing SSH"
ufw allow ssh

log "Allowing 80 / 8080 ports"
ufw allow 80
ufw allow 8080


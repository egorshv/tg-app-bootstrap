#!/usr/bin/env bash
set -Eeuo pipefail

# Usage:
#   sudo bash setup-https-nginx-ubuntu22.sh -m admin@example.com -d example.com [-d www.example.com] [--staging]
#
# Based on: https://certbot.eff.org/instructions?ws=nginx&os=snap

EMAIL=""
STAGING=0
DOMAINS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--email)
      EMAIL="$2"; shift 2 ;;
    -d|--domain)
      DOMAINS+=("$2"); shift 2 ;;
    --staging)
      STAGING=1; shift ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1 ;;
  esac
done

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0 ..."
  exit 1
fi

if [[ -z "$EMAIL" || ${#DOMAINS[@]} -eq 0 ]]; then
  echo "Error: set --email and at least one --domain"
  exit 1
fi

# Ubuntu 22 check (recommended)
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "22.04" ]]; then
    echo "Warning: script is designed for Ubuntu 22.04 (detected: ${PRETTY_NAME:-unknown})"
  fi
fi

apt-get update
apt-get install -y snapd nginx

systemctl enable --now snapd
systemctl enable --now nginx

# Optional: allow HTTP/HTTPS via UFW if active
if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
  ufw allow 'Nginx Full' || true
fi

snap install core || true
snap refresh core

apt-get remove -y certbot || true

snap install --classic certbot
ln -sf /snap/bin/certbot /usr/local/bin/certbot

nginx -t
systemctl reload nginx

CERTBOT_CMD=(certbot --nginx --non-interactive --agree-tos --redirect --email "$EMAIL")
for d in "${DOMAINS[@]}"; do
  CERTBOT_CMD+=(-d "$d")
done
if [[ "$STAGING" -eq 1 ]]; then
  CERTBOT_CMD+=(--staging)
fi

"${CERTBOT_CMD[@]}"

# Renewal test
certbot renew --dry-run

echo "HTTPS configured successfully for: ${DOMAINS[*]}"

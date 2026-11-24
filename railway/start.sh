#!/bin/sh
# Start script for Servas on Railway. Any failed step exits non-zero so Railway restarts the service.
set -eu

cd /app
DATA_DIR=/app/database/sqlite
mkdir -p "$DATA_DIR"

# --- Settings (fixed defaults; the template sets only what it must) -------------------------
export APP_NAME="${APP_NAME:-Servas}"
export APP_ENV=production
export APP_DEBUG="${APP_DEBUG:-false}"
export DB_CONNECTION=sqlite
export DB_DATABASE="$DATA_DIR/database.sqlite"
export DB_FOREIGN_KEYS=true
export LOG_CHANNEL="${LOG_CHANNEL:-stderr}"
export LOG_LEVEL="${LOG_LEVEL:-warning}"
export SESSION_DRIVER="${SESSION_DRIVER:-database}"
export CACHE_DRIVER="${CACHE_DRIVER:-file}"
export QUEUE_CONNECTION=sync
# Sign-up is closed: the owner account is created below. Set SERVAS_ENABLE_REGISTRATION=true to open it.
export SERVAS_ENABLE_REGISTRATION="${SERVAS_ENABLE_REGISTRATION:-false}"
export SERVAS_SHOW_APP_VERSION="${SERVAS_SHOW_APP_VERSION:-true}"

# APP_URL: use it only if it is a full http(s) URL with a host (Railway can resolve
# https://${{RAILWAY_PUBLIC_DOMAIN}} to plain "https://" when no domain exists yet).
case "${APP_URL:-}" in
  http://?*|https://?*) ;;
  *) if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then export APP_URL="https://${RAILWAY_PUBLIC_DOMAIN}"; else export APP_URL="http://localhost:${PORT:-8080}"; fi ;;
esac
case "$APP_URL" in https://*) export SESSION_SECURE_COOKIE="${SESSION_SECURE_COOKIE:-true}" ;; esac

# APP_KEY: Laravel needs 32 bytes (or base64:...). Derive a valid key from any other value
# so a wrong-length secret can't break every page.
if [ -z "${APP_KEY:-}" ]; then
  echo "servas: APP_KEY is empty; set it to a 32-character secret" >&2
  exit 1
fi
case "$APP_KEY" in
  base64:*) ;;
  *) if [ "$(printf %s "$APP_KEY" | wc -c)" -ne 32 ]; then
       APP_KEY="base64:$(php -r 'echo base64_encode(hash("sha256", getenv("APP_KEY"), true));')"
       export APP_KEY
     fi ;;
esac

# --- CPU-sized threads: Railway shows the host's CPUs, not the service's ------------------
cpus=1
if [ -r /sys/fs/cgroup/cpu.max ]; then
  read -r quota period < /sys/fs/cgroup/cpu.max || true
  if [ "${quota:-max}" != "max" ] && [ "${period:-0}" -gt 0 ]; then
    cpus=$(( (quota + period - 1) / period ))
  else
    cpus=$(nproc 2>/dev/null || echo 2)
  fi
fi
[ "$cpus" -lt 1 ] && cpus=1
[ "$cpus" -gt 8 ] && cpus=8
export GOMAXPROCS="${GOMAXPROCS:-$cpus}"
threads=$(( cpus * 2 ))
[ "$threads" -lt 4 ] && threads=4
export FRANKENPHP_NUM_THREADS="${FRANKENPHP_NUM_THREADS:-$threads}"

# --- Database, migrations and the owner account (public port still closed) -----------------
[ -f "$DB_DATABASE" ] || touch "$DB_DATABASE"
exec 9>"$DATA_DIR/.railway-init.lock"
flock -x 9 || { echo "servas: could not get the init lock" >&2; exit 1; }

php artisan config:clear -q
php artisan migrate --force --no-interaction -q
php /opt/railway/bootstrap-owner.php
flock -u 9

php artisan config:cache -q
php artisan view:cache -q

echo "servas: starting on port ${PORT} (${FRANKENPHP_NUM_THREADS} PHP threads, GOMAXPROCS=${GOMAXPROCS}), sign-up enabled: ${SERVAS_ENABLE_REGISTRATION}"
exec frankenphp run --config /etc/caddy/Caddyfile

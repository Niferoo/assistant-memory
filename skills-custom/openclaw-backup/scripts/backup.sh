#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-safe}"
BACKUP_DIR="${2:-$HOME/openclaw-backups}"
PASSPHRASE="${3:-}"
DATE="$(date +%Y-%m-%d_%H%M)"
ROOT="$HOME/.openclaw"

mkdir -p "$BACKUP_DIR"

rotate() {
  local pattern="$1"
  ls -t "$BACKUP_DIR"/$pattern 2>/dev/null | tail -n +8 | xargs -r rm -f
}

if [[ ! -d "$ROOT" ]]; then
  echo "❌ Missing $ROOT"
  exit 1
fi

case "$MODE" in
  safe)
    OUT="$BACKUP_DIR/openclaw-safe-$DATE.tar.gz"
    tar -czf "$OUT" -C "$HOME" .openclaw/workspace \
      --exclude='*.log' \
      --exclude='**/.git' \
      --exclude='**/node_modules'
    rotate "openclaw-safe-*.tar.gz"
    echo "✅ SAFE backup: $OUT"
    ;;

  full)
    if [[ -z "$PASSPHRASE" ]]; then
      echo "❌ Passphrase required for full mode"
      exit 1
    fi
    PLAIN="$BACKUP_DIR/openclaw-full-$DATE.tar.gz"
    ENC="$PLAIN.enc"
    tar -czf "$PLAIN" -C "$HOME" .openclaw --exclude='*.log'
    openssl enc -aes-256-cbc -pbkdf2 -salt -in "$PLAIN" -out "$ENC" -pass pass:"$PASSPHRASE"
    rm -f "$PLAIN"
    rotate "openclaw-full-*.tar.gz.enc"
    echo "✅ FULL encrypted backup: $ENC"
    ;;

  *)
    echo "Usage: ./backup.sh [safe|full] [backup_dir] [passphrase-for-full]"
    exit 1
    ;;
esac

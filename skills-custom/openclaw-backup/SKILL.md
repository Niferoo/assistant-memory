---
name: openclaw-backup
description: Create, rotate, verify, and restore OpenClaw backups on Windows or Linux. Use when user asks to back up agent memory/settings, schedule periodic backups, or recover after reinstall. Includes safe mode for Git-syncable data and full mode for local encrypted archives with secrets.
---

# OpenClaw Backup

Create backups in two modes:

1. **safe** (default): only hard-to-recover workspace context (Git-friendly, no secrets)
2. **full**: full `.openclaw` backup including credentials/session state (local encrypted archive only)

## Use Scripts

- **Windows (PowerShell)**: `scripts/backup.ps1`
- **Linux/macOS (bash)**: `scripts/backup.sh`

## Commands

### Safe backup (recommended for regular use)

```powershell
./scripts/backup.ps1 -Mode safe
```

```bash
./scripts/backup.sh safe
```

### Full encrypted backup (local only)

```powershell
./scripts/backup.ps1 -Mode full -Passphrase "STRONG_PASS"
```

```bash
./scripts/backup.sh full "STRONG_PASS"
```

## Output

Backups are written to:
- Windows: `$HOME/openclaw-backups`
- Linux/macOS: `~/openclaw-backups`

Naming:
- Safe: `openclaw-safe-YYYY-MM-DD_HHMM.zip|tar.gz`
- Full encrypted: `openclaw-full-YYYY-MM-DD_HHMM.zip.enc|tar.gz.enc`

## Rotation

Keep latest 7 backups per mode automatically.

## Restore

Read `references/restore.md` before restore. Always stop gateway first.

## Safety Rules

- Never push full backups (or decrypted archives) to GitHub.
- Treat passphrase as secret.
- Verify archive exists and is readable before replacing current data.

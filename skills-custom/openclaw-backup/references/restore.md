# Restore OpenClaw from Backup

## 1) Stop service

```bash
openclaw gateway stop
```

## 2) Safety snapshot of current state

```bash
mv ~/.openclaw ~/.openclaw-old
```

On Windows PowerShell:

```powershell
Rename-Item "$HOME\.openclaw" ".openclaw-old"
```

---

## Restore from SAFE backup

Use this when you backed up only workspace-level important files.

### Windows (zip)

```powershell
Expand-Archive "$HOME\openclaw-backups\openclaw-safe-YYYY-MM-DD_HHMM.zip" -DestinationPath "$HOME" -Force
```

### Linux/macOS (tar.gz)

```bash
tar -xzf ~/openclaw-backups/openclaw-safe-YYYY-MM-DD_HHMM.tar.gz -C ~
```

---

## Restore from FULL encrypted backup

### Windows

```powershell
openssl enc -d -aes-256-cbc -pbkdf2 -in "$HOME\openclaw-backups\openclaw-full-YYYY-MM-DD_HHMM.zip.enc" -out "$HOME\openclaw-backups\openclaw-full.zip" -pass pass:"YOUR_PASS"
Expand-Archive "$HOME\openclaw-backups\openclaw-full.zip" -DestinationPath "$HOME" -Force
```

### Linux/macOS

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -in ~/openclaw-backups/openclaw-full-YYYY-MM-DD_HHMM.tar.gz.enc -out ~/openclaw-backups/openclaw-full.tar.gz -pass pass:"YOUR_PASS"
tar -xzf ~/openclaw-backups/openclaw-full.tar.gz -C ~
```

---

## 4) Start and verify

```bash
openclaw gateway start
openclaw status
```

## Rollback if needed

If restore failed:

```bash
rm -rf ~/.openclaw
mv ~/.openclaw-old ~/.openclaw
openclaw gateway start
```

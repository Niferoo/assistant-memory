param(
  [ValidateSet("safe","full")]
  [string]$Mode = "safe",
  [string]$BackupDir = "$HOME/openclaw-backups",
  [string]$Passphrase = ""
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$root = "$HOME/.openclaw"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

function Rotate-Backups([string]$pattern) {
  $files = Get-ChildItem -Path $BackupDir -Filter $pattern -File | Sort-Object LastWriteTime -Descending
  if ($files.Count -gt 7) {
    $files | Select-Object -Skip 7 | Remove-Item -Force
  }
}

if (-not (Test-Path $root)) {
  throw "OpenClaw directory not found: $root"
}

if ($Mode -eq "safe") {
  $out = Join-Path $BackupDir "openclaw-safe-$timestamp.zip"
  $tmp = Join-Path $env:TEMP "openclaw-safe-$timestamp"

  if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null

  New-Item -ItemType Directory -Force -Path (Join-Path $tmp ".openclaw/workspace") | Out-Null
  Copy-Item "$root/workspace/*" (Join-Path $tmp ".openclaw/workspace") -Recurse -Force -ErrorAction SilentlyContinue

  Compress-Archive -Path (Join-Path $tmp ".openclaw") -DestinationPath $out -Force
  Remove-Item $tmp -Recurse -Force
  Rotate-Backups "openclaw-safe-*.zip"

  Write-Output "SAFE backup created: $out"
  exit 0
}

if ($Mode -eq "full") {
  if ([string]::IsNullOrWhiteSpace($Passphrase)) {
    throw "Passphrase is required for full mode"
  }

  $plain = Join-Path $BackupDir "openclaw-full-$timestamp.zip"
  $enc = "$plain.enc"

  Compress-Archive -Path $root -DestinationPath $plain -Force

  $openssl = Get-Command openssl -ErrorAction SilentlyContinue
  if (-not $openssl) {
    throw "OpenSSL not found. Install OpenSSL or use safe mode."
  }

  & openssl enc -aes-256-cbc -pbkdf2 -salt -in $plain -out $enc -pass "pass:$Passphrase"
  if ($LASTEXITCODE -ne 0) { throw "Encryption failed" }

  Remove-Item $plain -Force
  Rotate-Backups "openclaw-full-*.zip.enc"

  Write-Output "FULL encrypted backup created: $enc"
  exit 0
}

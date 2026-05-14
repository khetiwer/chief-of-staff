# launch-cos.ps1
# Launches the Chief of Staff Claude session cleanly.
# Kills any existing bun processes before starting to prevent zombie pollers
# stealing Telegram messages.

# ── Step 1: Kill existing bun processes ──────────────────────────────────────
$bun = Get-Process bun -ErrorAction SilentlyContinue

if ($bun) {
    Write-Host "Found $($bun.Count) bun process(es). Cleaning up..." -ForegroundColor Yellow
    $bun | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "Bun processes cleared." -ForegroundColor Green
} else {
    Write-Host "No bun processes running. Clean start." -ForegroundColor Green
}

# ── Step 2: Navigate to alfred workspace ─────────────────────────────────────
# Claude launches from the alfred workspace (per the brain/workspace split).
# Cross-cwd reads (brain\wiki\people, other workspaces) use absolute paths
# spelled out in CLAUDE.md and start-cos.md.
Set-Location "C:\Users\kheti\workspaces\alfred"

# ── Step 3: Launch Claude with Telegram channel enabled ──────────────────────
Write-Host ""
Write-Host "Launching COS..." -ForegroundColor Cyan
Write-Host "Once Claude opens, type:  /start-cos" -ForegroundColor DarkCyan
Write-Host ""

claude --channels plugin:telegram@claude-plugins-official

# PowerShell script to move common developer caches to D: and set environment variables.
# WARNING: This script moves directories and sets user environment variables. Review before running.

param(
    [switch]$WhatIf
)

function Safe-Move($source, $dest) {
    Write-Host "Moving $source -> $dest"
    if ($WhatIf) { return }
    if (-Not (Test-Path $source)) {
        Write-Host "Source not found: $source (skipping)" -ForegroundColor Yellow
        return
    }
    if (-Not (Test-Path $dest)) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }
    Get-ChildItem -Path $source -Force | ForEach-Object {
        Move-Item -Path $_.FullName -Destination $dest -Force
    }
}

Write-Host "This script will move common caches to D: and set user environment variables.`nReview and run with -WhatIf first to preview.`n" -ForegroundColor Cyan

# 1) Pub cache
$localPub = Join-Path $env:LOCALAPPDATA "Pub\Cache"
$destPub = 'D:\pub_cache'
Write-Host "PUB_CACHE: $destPub"
Safe-Move $localPub $destPub

# 2) Gradle user home
$localGradle = Join-Path $env:USERPROFILE ".gradle"
$destGradle = 'D:\.gradle'
Write-Host "GRADLE_USER_HOME: $destGradle"
Safe-Move $localGradle $destGradle

# 3) Android SDK (manual check)
Write-Host "If your Android SDK is on C:, move it manually (e.g. to D:\Android\sdk) and update SDK paths in local.properties or ANDROID_SDK_ROOT." -ForegroundColor Yellow

# 4) Set environment variables (persisted)
if (-Not $WhatIf) {
    Write-Host "Setting environment variables (persisted for current user)..."
    setx PUB_CACHE "D:\pub_cache"
    setx GRADLE_USER_HOME "D:\.gradle"
    # Do not overwrite ANDROID_SDK_ROOT unless you are sure where your SDK will live.
    Write-Host "Environment variables set. Restart your shell/IDE to pick them up." -ForegroundColor Green
} else {
    Write-Host "WhatIf mode, not setting environment variables." -ForegroundColor Yellow
}

Write-Host "Done. Verify directories and restart your shell/IDE." -ForegroundColor Green


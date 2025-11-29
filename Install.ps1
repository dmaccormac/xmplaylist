
# XMPlaylist Module Installation Script
# -------------------------------------
# This script downloads and installs the XMPlaylist PowerShell module
# from the specified GitHub repository release.
param (
    [string]$version = "1.2.8" ,
    [string]$branch = "test"
)

Write-Host "Installing XMPlaylist module version $version from branch $branch..." -ForegroundColor Cyan

# Define paths
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
$tempZip = "$env:TEMP\XMPlaylist.zip"
$target = Join-Path $modulePath "XMPlaylist"

# GitHub release URL (using version tag)
$uri = "https://github.com/dmaccormac/xmplaylist/archive/refs/heads/$branch.zip"
# Ensure module directory exists
if (-not (Test-Path $modulePath)) {
    Write-Host "Creating module directory: $modulePath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $modulePath -Force | Out-Null
}

# Download zip
try {
    Write-Host "Downloading from $uri..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $uri -OutFile $tempZip -ErrorAction Stop
} catch {
    Write-Host "Download failed: $_" -ForegroundColor Red
    exit 1
}

# Expand archive
try {
    Write-Host "Extracting archive..." -ForegroundColor Cyan
    Expand-Archive -Path $tempZip -DestinationPath $modulePath -Force
} catch {
    Write-Host "Extraction failed: $_" -ForegroundColor Red
    exit 1
}

# Define source path
$source = Join-Path $modulePath "xmplaylist-$branch"

if (-not (Test-Path $source)) {
    Write-Host "Source folder not found: $source" -ForegroundColor Red
    exit 1
}

# Remove existing target if present
if (Test-Path $target) {
    Write-Host "Removing existing XMPlaylist module..." -ForegroundColor Yellow
    Remove-Item $target -Recurse -Force
}

# Rename folder
Rename-Item -Path $source -NewName "XMPlaylist"

# Unblock files
Write-Host "Unblocking files..." -ForegroundColor Cyan
Get-ChildItem $target -Recurse | Unblock-File

# Import module
Write-Host "Importing XMPlaylist module..." -ForegroundColor Cyan
try {
    Import-Module XMPlaylist -Force -ErrorAction Stop
    Write-Host "XMPlaylist module imported successfully!" -ForegroundColor Cyan
} catch {
    Write-Host "Failed to import XMPlaylist module: $_" -ForegroundColor Red
    exit 1
}

# Append import statement to $PROFILE if not already present
$profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$importStatement = "Import-Module XMPlaylist"
if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath
    if ($profileContent -notcontains $importStatement) {
        Write-Host "Adding Import-Module statement to profile..." -ForegroundColor Cyan
        Add-Content -Path $profilePath -Value "`n$importStatement"
    } else {
        Write-Host "Import-Module statement already exists in profile." -ForegroundColor Yellow
    }
} else {
    Write-Host "Creating profile and adding Import-Module statement..." -ForegroundColor Cyan
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
    Add-Content -Path $profilePath -Value $importStatement
}

# Clean up
Remove-Item $tempZip -Force
Write-Host "Installation complete. You can now use the XMPlaylist module." -ForegroundColor Green

Write-Host "Available Commands:"
Get-Command -Module XMPlaylist

Write-Host "`nFor more information, visit: https://github.com/dmaccormac/XmPlaylist" -ForegroundColor Yellow
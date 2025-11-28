$version = "1.2.5"
Write-Host "Installing XMPlaylist module version $version..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://github.com/dmaccormac/xmplaylist/archive/refs/heads/test.zip" -OutFile "$env:TEMP\XMPlaylist.zip"
Expand-Archive "$env:TEMP\XMPlaylist.zip" -DestinationPath "$env:USERPROFILE\Documents\WindowsPowerShell\Modules" -Force
Rename-Item "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\xmplaylist-test" "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\XMPlaylist" -Force
Get-ChildItem "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\XMPlaylist" -Recurse | Unblock-File
Import-Module XMPlaylist -Force 

Write-Host "XMPlaylist module installed successfully." -ForegroundColor Green
Write-Host "Usage: Import-Module XMPlaylist" -ForegroundColor Yellow
Write-Host "Available Commands:" -ForegroundColor Yellow
Get-Command -Module XMPlaylist | Format-Table -AutoSize
Write-Host "For more information, visit: https://github.com/dmaccormac/XmPlaylist" -ForegroundColor Yellow

# XmPlaylist [test branch]

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). 
It allows users to retrieve useful data from API responses such as SiriusXM station data and recently played tracks.

## Installation
You can install the module by running the following command in PowerShell:

```powershell
Invoke-WebRequest -Uri "https://github.com/dmaccormac/xmplaylist/archive/refs/heads/test.zip" -OutFile "$env:TEMP\XMPlaylist.zip"; Expand-Archive "$env:TEMP\XMPlaylist.zip" -DestinationPath "$env:USERPROFILE\Documents\WindowsPowerShell\Modules" -Force; Rename-Item "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\xmplaylist-test" "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\XMPlaylist" -Force; Get-ChildItem "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\XMPlaylist" -Recurse | Unblock-File
```

## Usage

### Import the module
```powershell
Import-Module XMPlaylist
```

### Find commands
```powershell
Get-Command -Module XMPlaylist
```

## Functions

```
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Format-XMPlaylist                                  1.2.2      XmPlaylist
Function        Get-XMPlaylist                                     1.2.2      XmPlaylist
Function        Get-XMStation                                      1.2.2      XmPlaylist
Function        Invoke-XMPlaylist                                  1.2.2      XmPlaylist
Function        Show-XMPlayer                                      1.2.2      XmPlaylist
```
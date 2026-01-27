
# XmPlaylist

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). It allows users to retrieve useful data from API responses such as SiriusXM station data and recently played tracks.

## Installation
You can install the module by running the following command in PowerShell:

```powershell
Invoke-WebRequest -Uri "https://github.com/dmaccormac/xmplaylist/archive/refs/heads/main.zip" -OutFile "$env:TEMP\XMPlaylist.zip"; Expand-Archive "$env:TEMP\XMPlaylist.zip" -DestinationPath "$env:USERPROFILE\Documents\WindowsPowerShell\Modules" -Force; Rename-Item "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\xmplaylist-main" "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\XMPlaylist" -Force; Get-ChildItem "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\XMPlaylist" -Recurse | Unblock-File
```

## Usage

### Import the module
```powershell
Import-Module XMPlaylist
```

### Find commands
```powershell
Get-Command -Module XMPlaylist

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Format-XMPlaylist                                  1.3.5      XmPlaylist
Function        Get-XMPlaylist                                     1.3.5      XmPlaylist
Function        Get-XMStation                                      1.3.5      XmPlaylist

```

### Functions

#### Get-XMStation

Example #1:
```powershell
Get-XMStation
```
Retrieves a list of all available SiriusXM stations.


---

#### Get-XMPlaylist

Example #1:
```powershell
Get-XMPlaylist -Channel "siriusxmhits1"
```
Get recently played tracks for siriusxmhits1 channel.

---

#### Format-XMPlaylist

Formats a playlist item into a custom object with artist, title, link and timestamp.

Example #1:
```powershell
Get-XmPlaylist siriusxmhits1 | Format-XMPlaylist
```
Gets recently played tracks from siriusxmhits1 channel and formats them into an XmPlaylist object.

---
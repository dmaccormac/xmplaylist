
# XmPlaylist

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). 
It allows users to retrieve useful data from API responses such as SiriusXM station data and recently played tracks.

## Installation

```powershell
Invoke-WebRequest -Uri "https://github.com/dmaccormac/xmplaylist/archive/refs/heads/main.zip" -OutFile "$env:TEMP\XMPlaylist.zip"; Expand-Archive "$env:TEMP\XMPlaylist.zip" -DestinationPath "$env:USERPROFILE\Documents\WindowsPowerShell\Modules" -Force; Rename-Item "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\xmplaylist-main" "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\XMPlaylist" -Force; Get-ChildItem "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\XMPlaylist" -Recurse | Unblock-File
```

# Usage

### Import the module
```powershell
Import-Module XMPlaylist
```

### Find commands
```powershell
Get-Command -Module XMPlaylist
```

### Functions

#### Get-XMStation
Retrieves a list of all available SiriusXM stations.

Example #1
```powershell
Get-XMStation
```
Retrieves JSON object containing all station information.

Example #2
```powershell
$(Get-XMStation).results | Select-Object -Property number, name, shortDescription
```
View station list including number, name and description properties.

---

#### Get-XMPlaylist
Get recently played tracks for SiriusXM channel.

Example #1
```powershell
Get-XMPlaylist 
```
Retrieves recently played tracks for all channels.

Example #2 
```powershell
Get-XMPlaylist -Channel "siriusxmhits1"
```
Get recently played tracks for siriusxmhits1 channel.

---

#### Format-XMPlaylistItem

Formats a playlist item into a custom object with artist, title, link and timestamp.

```powershell
$item = $(Get-XMPlaylist).results | Select-Object -First 1
$processed = Format-XMPlaylistItem -Item $item
$processed | Format-Table
```
Gets the most recently played track, formats it a PowerShell object and output it in table format.

---

### Invoke-XMItemPlayback
This function takes a formatted playlist item (as returned by Format-XMPlaylistItem) and plays the track using yt-dlp to fetch the audio stream and ffplay to play it.

```powershell
    $(Get-XMPlaylist siriusxmhits1).results | ForEach-Object { Invoke-XMItemPlayback -Item (Format-XMPlaylistItem $_) }
```

---

## Author
**Dan MacCormac <dmaccormac@gmail.com>**

---
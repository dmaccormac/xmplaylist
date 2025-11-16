
# XmPlaylist

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). 
It allows users to retrieve useful data from API responses such as SiriusXM station data and recently played tracks.

## Installation
You can install the module by running the following command in PowerShell:

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

Example #1:
```powershell
Get-XMStation
```
Retrieves JSON object containing all station information.

Example #2:
```powershell
$(Get-XMStation).results | Select-Object -Property number, name, shortDescription
```
View station list including number, name and description properties.

---

#### Get-XMPlaylist
Get recently played tracks for SiriusXM channel.

Example #1:
```powershell
Get-XMPlaylist 
```
Retrieves recently played tracks for all channels.

Example #2:
```powershell
Get-XMPlaylist -Channel "siriusxmhits1"
```
Get recently played tracks for siriusxmhits1 channel.

---

#### Format-XMPlaylistItem

Formats a playlist item into a custom object with artist, title, link and timestamp.

Example #1:
```powershell
$(Get-XMPlaylist siriusxmhits1).results | ForEach-Object {Format-XMPlaylistItem $_}
```
Gets the most recently played tracks from siriusxmhits1 channel and formats each item into XmPlaylistItem object.

---

### Invoke-XMPlaylistItem
This function takes an XMPlaylistItem containing a YouTube link and plays the track using yt-dlp to fetch the audio and ffplay to play it.

Example #1:
```powershell
$(Get-XMPlaylist siriusxmhits1).results | ForEach-Object { Invoke-XMPlaylistItem -Item (Format-XMPlaylistItem $_) }
```
Invokes all recently played items for the siriusxmhits1 station. 

---

## Author
**Dan MacCormac <dmaccormac@gmail.com>**

---
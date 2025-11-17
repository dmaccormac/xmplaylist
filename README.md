
# XmPlaylist [experimental]

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). It allows users to retrieve useful data from API responses such as SiriusXM station data and recently played tracks.

## Installation

```powershell
Invoke-WebRequest -Uri "https://github.com/dmaccormac/xmplaylist/archive/refs/heads/experimental.zip" -OutFile "$env:TEMP\XMPlaylist.zip"; Expand-Archive "$env:TEMP\XMPlaylist.zip" -DestinationPath "$env:USERPROFILE\Documents\WindowsPowerShell\Modules" -Force; Rename-Item "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\xmplaylist-experimental" "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\XMPlaylist" -Force; Get-ChildItem "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\XMPlaylist" -Recurse | Unblock-File
   ```

<<<<<<< Updated upstream
=======
## Usage
>>>>>>> Stashed changes

## Functions

<<<<<<< Updated upstream
### Get-XMStation
Retrieves a list of all available SiriusXM stations.

```powershell
Get-XMStation
```

---

### Get-XMPlaylist
Retrieves recently played tracks for feed or channel.

Get recently played tracks for all channels (feed).
```powershell
Get-XMPlaylist 
```

Get recently played tracks for siriusxmhits1 channel.
```powershell
Get-XMPlaylist -Channel "siriusxmhits1"
```


---

### Format-XMPlaylistItem
This function takes a playlist item object (as returned by Get-XMPlaylist) and extracts key information such as artist, title, link, and timestamp.
It returns a custom PowerShell object with these properties for easier consumption.

```powershell
$processed = Format-XMPlaylistItem -Item $item
$processed | Format-Table
```

---

### Invoke-XMTrack
This function takes a formatted playlist item (as returned by Format-XMPlaylistItem) and plays the track using yt-dlp to fetch the audio stream and ffplay to play it.

```powershell
$item = $(Get-XMPlaylist).results | Select-Object -First 1 | Format-XMPlaylistItem
Invoke-Track -Item $item
```

---

### Start-XMPlaylist
This function takes a takes a SiriusXM channel name, retrieves its playlist using Get-XMPlaylist, formats each item with Format-XMPlaylistItem, and plays each track using Invoke-Track.

```powershell
Start-XMPlaylist siriusxmhits1
```

---

### Show-XMPlayer
This function retrieves the list of available SiriusXM stations, displays them in a grid view for user selection, and then starts playing the selected station's playlist (via Start-XMPlaylist fxn).

---

## Author
**Dan MacCormac <dmaccormac@gmail.com>**

---
=======
### Find commands
```powershell
Get-Command -Module XMPlaylist
```

## Functions

```
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Format-XMPlaylist                                  1.3.4      XmPlaylist
Function        Get-XMPlaylist                                     1.3.4      XmPlaylist
Function        Get-XMStation                                      1.3.4      XmPlaylist
Function        Invoke-XMPlaylist                                  1.3.4      XmPlaylist
Function        Show-XMPlayer                                      1.3.4      XmPlaylist
```
>>>>>>> Stashed changes

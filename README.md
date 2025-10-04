
# XmPlaylist [experimental]

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). It allows users to retrieve useful data from API responses such as SiriusXM station data and recently played tracks.

## Installation

1. Download and extract the module folder.
2. Open PowerShell and import the module:
   ```powershell
   Import-Module "Path\To\XmPlaylist\XmPlaylist.psm1"
   ```


## Functions

### `Get-XMStation`
Retrieves a list of all available SiriusXM stations.

```powershell
Get-XMStation
```

---

### `Get-XMPlaylist`
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

### Start-XMPlaylist
Plays a playlist of tracks using yt-dlp and ffplay. 

### Show-XMPlayer
This function retrieves the list of available SiriusXM stations, displays them in a grid view for user selection, and then starts playing the selected station's playlist (via Start-XMPlaylist fxn).


## Author
**Dan MacCormac <dmaccormac@gmail.com>**

---
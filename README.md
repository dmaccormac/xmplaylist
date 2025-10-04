
# XmPlaylist

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). 
It allows users to retrieve useful data from API responses such as SiriusXM station data and recently played tracks.

## Installation

1. Download and extract the module folder.
2. Open PowerShell and import the module:
   ```powershell
   Import-Module "Path\To\XmPlaylist\XmPlaylist.psm1"
   ```


## Functions

### `Get-XMStation`
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

### `Get-XMPlaylist`
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

### Format-XMPlaylistItem

Formats a playlist item into a custom object with artist, title, link and timestamp.

```powershell
$item = $(Get-XMPlaylist).results | Select-Object -First 1
$processed = Format-XMPlaylistItem -Item $item
$processed | Format-Table
```
Gets the most recently played track, formats it a PowerShell object and output it in table format.

## Author
**Dan MacCormac <dmaccormac@gmail.com>**

---
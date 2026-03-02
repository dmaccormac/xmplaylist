# XmPlaylist

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). It allows users to retrieve SiriusXM station metadata and recently played tracks.

## Installation

Run the installation command in Windows Terminal:

```powershell
irm https://tinyurl.com/xmplaylist | iex
```

## Usage
### Enable running scripts (if required)
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Import the module
```powershell
Import-Module XmPlaylist
```

### List exported functions
```powershell
Get-Command -Module XmPlaylist
```

You should see the list of functions:

```
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Get-XMPlaylist                                     1.4.1      XmPlaylist
Function        Get-XMStation                                      1.4.1      XmPlaylist
Function        Show-XMPlaylistPicker                              1.4.1      XmPlaylist
```

### Functions

#### Get-XMStation
Retrieves SiriusXM stations from the xmplaylist.com API. By default the function returns converted station objects. 

Parameters:
- `-Filter <string>`: optional search term that filters results by all searchable fields.
- `-Raw`: return the raw API response.

Examples:

```powershell
# List all stations (converted objects)
Get-XMStation | Select-Object -First 10

# Filter stations with partial match
Get-XMStation -Filter rock

# Get raw API response
Get-XMStation -Raw
```

----

#### Get-XMPlaylist
Retrieves the playlist for a specified SiriusXM channel.

Parameters:
- `-Channel <string>`: deeplink name of the channel (e.g., "siriusxmhits1").
- `-Link <string>`: the site to extract links from (default `youtube`). 
- `-Size <int>`: how many items to fetch (default is 24 items).
- `-Raw`: return the raw API response.

Example:

```powershell
Get-XMPlaylist -Channel "siriusxmhits1" -Size 20 -Link appleMusic
```

### Show-XMPlaylistPicker
Shows all stations in an Out-GridView for selection, then retrieves the playlist for the selected station.

Parameters:
- `-Link <string>`: the site to extract links from (default `youtube`). 
- `-Size <int>`: how many items to fetch (default is 24 items).

Example:

```powershell
Show-XMPlaylistPicker -Link youtubeMusic -Size 40
```

----




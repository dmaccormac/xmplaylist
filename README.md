# XmPlaylist

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). It allows users to retrieve SiriusXM station metadata and recently played track playlists.

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
Function        Get-Station
Function        Get-Playlist
```

### Functions

#### Get-Station
Retrieves SiriusXM stations from the xmplaylist.com API. By default the function returns converted station objects. 

Parameters:
- `-Filter <string>`: optional search term that filters results by Name, Deeplink, Number or ShortDescription.
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

#### Get-Playlist
Retrieves the playlist for a specified SiriusXM channel.

Parameters:
- `-Channel <string>`: deeplink name of the channel (e.g., "siriusxmhits1").
- `-Link <string>`: the site to extract links from (default `youtube`). 
- `-PageCount <int>`: how many pages to fetch (each page ~24 items).
- `-Raw`: return the raw API response.

Example:

```powershell
Get-XMPlaylist -Channel "siriusxmhits1" -PageCount 2 -Link spotify
```

----




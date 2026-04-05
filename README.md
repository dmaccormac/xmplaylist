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

### List available functions
```powershell
Get-Command -Module XmPlaylist
```

Example output:
```
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Get-XMPlaylist                                     1.4.3      XmPlaylist
Function        Get-XMStation                                      1.4.3      XmPlaylist
Function        Show-XMPlaylist                                    1.4.3      XmPlaylist
Function        Show-XMPlaylistSelection                           1.4.3      XmPlaylist
```
### Getting help

```powershell
Get-Help Get-XmPlaylist -Full
```

## Functions

#### Get-XMStation
Retrieves the list of available SiriusXM stations. 

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
- `-Channel <string>`: the name/number/deeplink of the channel (e.g., "siriusxmhits1").
- `-Link <string>`: the site to extract links from (default `youtube`). 
- `-Size <int>`: how many items to fetch (default is 24 items).
- `-Raw`: return the raw API response.

Example:

```powershell
Get-XMPlaylist -Channel "siriusxmhits1" -Size 20 -Link appleMusic
```

#### Show-XMPlaylist
 Displays the playlist for a specified SiriusXM channel in the console with pagination.

Parameters:
- `Channel <String>`: the name/number/deeplink of the SiriusXM channel (e.g., "siriusxmhits1")
- `-Link <string>`: the site to extract links from (default `youtube`). 

Example:

```powershell
Show-XMPlaylist 2 #Show playlist for channel 2 (siriusxmhits1)
```

#### Show-XMPlaylistSelection
Shows all stations in an Out-GridView for selection, then retrieves the playlist for the selected station.

Parameters:
- `-Link <string>`: the site to extract links from (default `youtube`). 

Example:

```powershell
Show-XMPlaylistSelection -Link spotify
```

----




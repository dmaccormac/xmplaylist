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
Function        Get-XMPlaylist                                     1.4.5      XmPlaylist
Function        Get-XMStation                                      1.4.5      XmPlaylist
Function        Show-XMPlaylist                                    1.4.5      XmPlaylist
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
Get-XMStation # List all stations 

Get-XMStation -Filter rock # Filter stations by keyword

Get-XMStation -Raw # Get raw API response
```

----

#### Get-XMPlaylist
Retrieves the playlist for a specified SiriusXM channel.

Parameters:
- `-Channel <string>`: the name/number/deeplink of the channel (e.g., "siriusxmhits1").
- `-Link <string>`: the site to extract links from (default `youtube`). 
- `-Size <int>`: how many items to fetch (default is 24 items).
- `-Raw`: return the raw API response.

Examples:

```powershell
Get-XMPlaylist # retrieves the default feed (all channels)

Get-XMPlaylist 2 # Get one page of tracks for channel 2 (Sirius XM Hits 1)

Get-XMPlaylist -Channel "siriusxmhits1" -Size 20 -Link appleMusic 
 # Get 20 tracks with Apple Music links from channel Sirius XM Hits 1

Get-Station -Filter jazz | Get-XMPlaylist -Size 10
# Find all stations with keyword 'jazz' and get a playlist of 10 items for each station
```

----

#### Show-XMPlaylist
 Displays the playlist for a specified SiriusXM channel in the console with pagination. 
 If a channel is not specified, it prompts the user to select a channel from the list.

Parameters:
- `-Channel <String>`: the name/number/deeplink of the SiriusXM channel (e.g., "siriusxmhits1").
- `-Link <string>`: the site to extract links from (default `youtube`). 

Examples:

```powershell
Show-XMPlaylist # Prompts the user to select a channel from the list
```

```powershell
Show-XMPlaylist 2 # Show playlist for channel 2 (siriusxmhits1)
```

----




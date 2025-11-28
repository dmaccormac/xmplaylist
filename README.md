
# XmPlaylist [test branch]

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). 
It allows users to retrieve useful data from API responses such as SiriusXM station data and recently played tracks.

## Installation
You can install the module by running the following command in PowerShell:

```powershell
irm https://raw.githubusercontent.com/dmaccormac/xmplaylist/refs/heads/test/Install.ps1 | iex
```

## Usage

### Import the module
```powershell
Import-Module XMPlaylist
```

### Find commands
```powershell
Get-Command -Module XMPlaylist
```

## Functions

```
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Format-XMPlaylist                                  1.2.6      XmPlaylist
Function        Get-XMPlaylist                                     1.2.6      XmPlaylist
Function        Get-XMStation                                      1.2.6      XmPlaylist
Function        Invoke-XMPlaylist                                  1.2.6      XmPlaylist
Function        Show-XMPlaylistHelper                              1.2.6      XmPlaylist
Function        Test-XMPlaylist                                    1.2.6      XmPlaylist
```
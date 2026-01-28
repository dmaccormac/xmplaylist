
# XmPlaylist

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). It allows users to retrieve useful data from API responses such as SiriusXM station data and recently played tracks.

## Installation
You can install the module by running the following command in PowerShell:

```powershell
 irm https://tinyurl.com/xmplaylist | iex 
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

```
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Get-XMPlaylist                                     1.3.6      XmPlaylist
Function        Get-XMStation                                      1.3.6      XmPlaylist
```


### Functions

#### Get-XMStation
This function calls the xmplaylist.com API to fetch a list of all available SiriusXM stations.

```powershell
Get-XMStation
```
Retrieves all SiriusXM stations.

---

#### Get-XMPlaylist
This function calls the xmplaylist.com API to fetch the playlist for the specified SiriusXM channel.

```powershell
Get-XMPlaylist -Channel "siriusxmhits1"
```
Get recently played tracks for siriusxmhits1 channel.

---


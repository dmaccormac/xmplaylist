1.3.7
- Add -Raw parameter to Get-XMPlaylist and Get-XMStation
- Refactor code
- Update help

1.3.8
- Add -Filter parameter to Get-XMStation
- Update ConvertFrom-APIStation function
- Update README.md

1.3.9
- Update Get-XMStation
- Add -Filter parameter to Get-XMPlaylist

1.4.0
- Update Get-XMStation
    - Update filtering logic and add -Exact switch
    - Remove deeplink field from default output
- Update Get-XMPlaylist
    - Update filtering logic and add -Exact switch
    - Show default feed if no channel specified
    - Specify channel by name, number, deeplink
    - Add support to pass station objects directly from Get-Station
    - Add pipeline support for -Channel parameter
    - Add support for multiple channel input items 

- Update ConvertFrom-ApiPlaylist
    - Update formattedItem
        - Add Channel field 
        - Create PSType XMPlaylist.Track for better output
        - Use $null instead of 'Unknown' for empty fields
        - Filter out items without a link

- Update ConvertFrom-ApiStation
    - Use $null instead of 'Unknown' for empty fields

- Add New-XmPlaylistHelper function
    - Demonstrate usage of Get-XMStation and Get-XmPlaylist

1.4.1
- Add Size parameter to Get-XMPlaylist
- Update function Show-XMPlaylistPicker
- Update README.md

1.4.2
- Update Get-XMPlaylist -Size parameter validation

1.4.3
- Rename Show-XMPlaylistPicker to Show-XMPlaylistSelection
- Update Show-XMPlaylistSelection output
- Add Show-XMPlaylist function

1.4.4
- Update Show-XMPlaylist function
- Update Show-XMPlaylistSelection function
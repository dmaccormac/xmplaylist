@{
    RootModule = 'XmPlaylist.psm1'
    ModuleVersion = '1.3.2'
    GUID = 'd3f8c8e2-9f4b-4b6a-8e2c-1a2b3c4d5e6f'
    Author = 'Dan MacCormac'
    Description = 'PowerShell module for accessing xmplaylist.com API'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Get-Station', 'Get-Playlist', 'Format-PlaylistItem', 'Invoke-ItemPlayback')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    DefaultCommandPrefix = 'XM'
}
    
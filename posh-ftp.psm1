Get-ChildItem -Path $PSScriptRoot\*Functions\* | ForEach-Object -Process {
    . $_
}
Get-ChildItem -Path $PSScriptRoot\WIP\* | ForEach-Object -Process {
    . $_
}

Export-ModuleMember -Function '*-FTP*'
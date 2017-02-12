# posh-ftp
A PowerShell module for working with FTP. The module works but is still a work in progress and is therefore not published to PowerShell Gallery.

Pullrequests are welcome!

## Example
```PowerShell
Import-Module -Name posh-ftp
$Credential = Get-Credential  
$ComputerName = 'ftp://waws-prod-rx4-052.ftp.azurewebsites.windows.net'  
$Session = New-FTPSession -ComputerName $ComputerName -Credential $Credential -Port 21 -Passive $true  
Get-FTPChildItem -Session $Session -Path '/'  
```

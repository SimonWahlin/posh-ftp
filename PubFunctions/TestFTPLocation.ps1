Function Test-FTPLocation {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.Net.FtpWebRequest]
        $Session,
        
        [Parameter(Mandatory=$false)]
        [String]
        $Path
    )
    try
    {
        $Null = Get-FTPChildItem @PSBoundParameters
        Write-Output -InputObject $true
    }
    catch
    {
        Write-Output -InputObject $false
    }
    finally
    {
        
    }
}
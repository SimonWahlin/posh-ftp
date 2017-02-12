Function Get-FileSize {
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
        $Request = New-FTPSession @PSBoundParameters -Method GetFileSize
        $FTPResponse = $Request.GetResponse()
        Write-Output -InputObject $FTPResponse.ContentLength  
    }
    catch
    {
        throw
    }
    finally
    {
        try
        {
            $FTPResponse.Close()
            $FTPResponse.Dispose()    
        }
        Catch{}
            
    }
}
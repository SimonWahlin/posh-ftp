Function Rename-FTPItem {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.Net.FtpWebRequest]
        $Session,
        
        [Parameter(Mandatory=$true)]
        [String]
        $Path,
        
        [Parameter(Mandatory=$true)]
        [String]
        $RenameTo
    )
    try
    {
        $RequestItem = Get-FTPItem @PSBoundParameters
        
        $Method = 'Rename'
        
        $Request = $Request = New-FTPSession @PSBoundParameters -Method $Method
        $FTPResponse = $Request.GetResponse()
        Write-Verbose -Message $FTPResponse.StatusDescription
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
        catch
        {
            
        }
    }
}
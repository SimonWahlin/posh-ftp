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
        $NewName
    )
    try
    {
        $Method = 'Rename'
        
        $Request = New-FTPSession -Session $Session -Path $Path -Method $Method
        $Request.RenameTo = $NewName
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
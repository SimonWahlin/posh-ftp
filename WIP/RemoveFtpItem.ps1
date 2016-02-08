Function Remove-FTPItem {
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
        $RequestItem = Get-FTPItem @PSBoundParameters
        if($RequestItem.PSISContainer)
        {
            $Method = 'RemoveDirectory'
        }
        else
        {
            $Method = 'DeleteFile'
        }
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
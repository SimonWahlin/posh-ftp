Function Test-IsFolder {
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
        if(Test-FTPLocation @PSBoundParameters -ErrorAction Stop)
        {
            try
            {
                $null = Get-FileSize @PSBoundParameters -ErrorAction Stop
                return $false
            }
            catch
            {
                return $true
            }
        }
    }
    catch
    {
        throw
    }
    finally
    {
    }
}
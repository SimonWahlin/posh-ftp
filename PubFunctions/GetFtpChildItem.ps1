Function Get-FTPChildItem
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Net.FtpWebRequest]
        $Session,
        
        [Parameter(Mandatory=$false)]
        [String]
        $Path,
        
        [Parameter(Mandatory=$false,ParameterSetName='detailed')]
        [Switch]
        $Detailed,
        
        [Parameter(Mandatory=$false,ParameterSetName='detailed')]
        [Switch]
        $AsString
    )
    Try
    {
        if($Detailed)
        {
            $Method = 'ListDirectoryDetails'
        }
        else
        {
            $Method = 'ListDirectory'
        }
        if($PSBoundParameters.ContainsKey('Detailed')){$null = $PSBoundParameters.Remove('Detailed')}
        if($PSBoundParameters.ContainsKey('AsString')){$null = $PSBoundParameters.Remove('AsString')}
        $Request = New-FTPSession @PSBoundParameters -Method $Method
        $FTPResponse = $Request.GetResponse()
        $FTPStream   = $FTPResponse.GetResponseStream()
        $FTPReader   = New-Object -TypeName System.IO.StreamReader -ArgumentList $FTPStream
        
        While(-Not ($FTPReader.EndOfStream))
        {
            Try {
                if($Detailed -and (-Not $AsString))
                {
                    $FTPReader.ReadLine() | ConvertFrom-FTPDirectoryDetails -ErrorAction Stop -Path $Request.RequestUri.AbsolutePath
                }
                else
                {
                    $FTPReader.ReadLine()
                }
            }
            Catch
            {
                Throw $_
            }
        }
    }
    Catch
    {
        Throw
    }
    Finally
    {
        Try
        {
            $FTPReader.Close()
            $FTPReader.Dispose()
            $FTPStream.Close()
            $FTPStream.Dispose()
            $FTPResponse.Close()
            $FTPResponse.Dispose()
        }
        Catch
        {
            
        }
    }
}
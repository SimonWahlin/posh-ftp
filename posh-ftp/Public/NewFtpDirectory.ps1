Function New-FTPDirectory
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [System.Net.FtpWebRequest]
        $Session,
        [Parameter(Mandatory=$false)]
        [String]
        $Path,
        [Parameter(Mandatory=$true)]
        [String]
        $Name
    )
    $Params = @{
        Session = $Session
        Method  = 'MakeDirectory'
    }
    if($PSBoundParameters.ContainsKey('Path'))
    {
        $Params['Path'] = (Join-Path -Path $Path -ChildPath $Name) -replace '\\','/'
    }
    else
    {
        $Params['Path'] = '{0}/{1}' -f $Session.RequestUri.AbsolutePath,($Name -replace '^/|/$')
    }
    Write-Verbose -Message ('Creating path: {0}' -f $Params.Path)
    if(-Not (Test-FTPLocation -Session $Session -Path $Params.Path) )
    {
        $Request = New-FTPSession @Params
        Try {
            $Result=$Request.GetResponse()
        }
        Catch {
            Write-Verbose -Message 'Failed to create Dir'
            Return
        }
        Write-Verbose -Message $Result.StatusDescription
    }
    else
    {
        Write-Verbose -Message 'Path already exists'
    }
}
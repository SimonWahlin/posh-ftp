Function New-FTPSession
{
    [CmdletBinding(
    	ConfirmImpact='Low'
    )]
    [OutputType([System.Net.FtpWebRequest])]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Session')]
        [System.Net.FtpWebRequest]
        $Session,

		[Parameter(Mandatory=$true,ParameterSetName='Session')]
        [String]
		[ValidateSet('DownloadFile', 'ListDirectory', 'UploadFile', 'DeleteFile', 'AppendFile', 'GetFileSize', 'UploadFileWithUniqueName', 'MakeDirectory', 'RemoveDirectory', 'ListDirectoryDetails', 'GetDateTimestamp', 'PrintWorkingDirectory', 'Rename')]
        $Method,

        [Parameter(Mandatory=$false,ParameterSetName='Session')]
        [String]
        $Path,

		[Parameter(Mandatory=$true,ParameterSetName='New')]
		[String]
        $ComputerName,

        [Parameter(Mandatory=$false,ParameterSetName='New')]
		[Int]
        $Port = 21,
		
        [Parameter(Mandatory=$false,ParameterSetName='New')]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,
        
        [Parameter(Mandatory=$false,ParameterSetName='New')]
        [Bool]
        $EnableSsl = $False,
		
        [Parameter(Mandatory=$false,ParameterSetName='New')]
        [Bool]
        $IgnoreCert = $False,
		
        [Parameter(Mandatory=$false,ParameterSetName='New')]
        [Bool]
        $KeepAlive = $True,
		
        [Parameter(Mandatory=$false,ParameterSetName='New')]
        [Parameter(Mandatory=$false,ParameterSetName='Session')]
        [Bool]
        $Binary = $False,
		
        [Parameter(Mandatory=$false,ParameterSetName='New')]
        [Bool]
        $Passive = $False,

		[Parameter(Mandatory=$false,ParameterSetName='New')]
        [String]
        $ConnectionGroupName = 'posh-FTP'
	)
    $ErrorActionPreference = 'Stop'

    Try
    {
        if($IgnoreCert){Disable-CertificateValidation}
	    Switch ($PSCmdlet.ParameterSetName)
		{
			'New'
			{
                $RequestUri = '{0}:{1}' -f ($ComputerName -replace '(?<prefix>ftp://)?(?<address>.+?)/?$','ftp://${address}'),$Port
        		[System.Net.FtpWebRequest]$Request = [System.Net.WebRequest]::Create($RequestUri)
                Write-Verbose -Message ('Request URI set to: [{0}]' -f $RequestUri)
				$Request.Credentials         = $Credential
				$Request.EnableSsl           = $EnableSsl
				$Request.KeepAlive           = $KeepAlive
				$Request.UseBinary           = $Binary
				$Request.UsePassive          = $Passive
				$Request.ConnectionGroupName = $ConnectionGroupName
				$Request.Method              = [System.Net.WebRequestMethods+FTP]::ListDirectoryDetails

				$Response = $Request.GetResponse()
				Write-Verbose -Message $Response.StatusDescription
				Write-Verbose -Message $Response.BannerMessage
				Write-Verbose -Message $Response.WelcomeMessage
			}
			'Session'
			{
                if($PSBoundParameters.ContainsKey('Path'))
                {
                    $ServerUri = ($Session.RequestUri.AbsoluteUri -replace ('{0}$' -f $Session.RequestUri.AbsolutePath))
                    $RequestUri = '{0}/{1}' -f $ServerUri,($Path -replace '^/|/$','')
                }
                else
                {
                    $RequestUri = $Session.RequestUri
                }
                [System.Net.FtpWebRequest]$Request = [System.Net.WebRequest]::Create($RequestUri)
				$Request.Credentials         = $Session.Credentials
				$Request.EnableSsl           = $Session.EnableSsl
				$Request.KeepAlive           = $Session.KeepAlive
				$Request.UseBinary           = $Session.UseBinary
				$Request.UsePassive          = $Session.UsePassive
				$Request.ConnectionGroupName = $Session.ConnectionGroupName
				$Request.Method              = [System.Net.WebRequestMethods+FTP]::$Method
			}
		}
        Write-Output -InputObject $Request
    }
    Catch
    {
        Throw
    }
}
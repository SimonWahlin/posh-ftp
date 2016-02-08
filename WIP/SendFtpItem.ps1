Function Send-FTPItem
{
    [CmdletBinding(
        ConfirmImpact='Low'
    )]
    Param(
        [Parameter(Mandatory=$true)]
        [System.Net.FtpWebRequest]
        $Session,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [Alias('FullName')]
        [String]
        $LocalFilePath,

        [Parameter(Mandatory=$false)]
        [String]
        $RemoteFilePath,

        [Parameter(Mandatory=$false)]
        [Bool]
        $Binary,
        
        [Parameter(Mandatory=$false)]
        [UInt32]
        $BufferSize = 20KB
    )
    Process
    {
        Try
        {
            $LocalFile = Get-Item -Path $LocalFilePath -ErrorAction Stop
        }
        Catch
        {
            Trow
        }
        $Params = @{
            Session = $Session
            Method  = 'UploadFile'
        }
        if($PSBoundParameters.ContainsKey('RemoteFilePath'))
        {
            $Params['Path'] = (Join-Path -Path $RemoteFilePath -ChildPath $LocalFile.name) -replace '\\','/'
        }
        else
        {
            $Params['Path'] = '{0}/{1}' -f ($Session.RequestUri.AbsolutePath -replace '/$'),$LocalFile.Name
        }
        if($PSBoundParameters.ContainsKey('Binary'))
        {
            $Params['Binary'] = $Binary
        }

        $Request = New-FTPSession @Params -Verbose
        $FileStream = [IO.File]::OpenRead($LocalFile.FullName)
        $RequestStream = $Request.GetRequestStream()
        [Byte[]]$Buffer = New-Object -TypeName 'Byte[]' -ArgumentList $BufferSize
        $ReadData = 0
        Write-Verbose -Message ('Uploading file: {0}' -f $Request.RequestUri)
        Try
        {
            Do {
                Write-Progress -Activity "Uploading file: $($Request.RequestUri)" -Status 'Uploading...' -PercentComplete ([Math]::Round(($ReadData/$LocalFile.Length)*100)) -Id 1
                $CurrentBuffer = $FileStream.Read($Buffer, 0, $Buffer.Length)
                $RequestStream.Write($Buffer, 0, $CurrentBuffer)
                $ReadData += $CurrentBuffer
            } While ($CurrentBuffer -gt 0)
        }
        Catch
        {
            Throw
        }
        Write-Progress -Completed -Id 1 -Activity "Uploading file: $($Request.RequestUri)"
        $FileStream.Close()
        $FileStream.Dispose()
        $RequestStream.Close()
        $RequestStream.Dispose()
    
        Write-Verbose -Message ($Request.GetResponse()).StatusDescription
    }
}
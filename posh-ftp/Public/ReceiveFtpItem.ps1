Function Receive-FTPItem
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.Net.FtpWebRequest]
        $Session,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [Alias('FullName')]
        [String]
        $RemotePath,

        [Parameter(Mandatory=$false)]
        [String]
        $LocalPath = $PWD.Path,

        [Parameter(Mandatory=$false)]
        [Bool]
        $Binary = $false,
        
        [Parameter(Mandatory=$false)]
        [UInt32]
        $BufferSize = 20KB
    )
    Process
    {
        Try
        {
            Try
            {
                Write-Verbose -Message "Receive-FTPItem, LocalPath: $LocalPath, RemotePath: $RemotePath"
                $LocalFile = Get-Item -Path $LocalPath -ErrorAction Stop
                if($LocalFile.PSIsContainer)
                {
                    Write-Verbose -Message 'LocalPath is a directory.' 
                    $TargetPath = Join-Path -Path $LocalFile.FullName -ChildPath (Split-Path -Path $RemotePath -Leaf)
                    Write-Verbose -Message "TargetPath now set to: $TargetPath"
                }
                else
                {
                    $TargetPath = $LocalPath
                }
            }
            Catch
            {
                if(-Not(Test-Path -Path (Split-Path -Parent $LocalPath) -PathType Container))
                {
                    $null = New-Item -ItemType Directory -Path (Split-Path -Parent $LocalPath) -ErrorAction Stop
                }
            }

            $RemoteItem = Get-FTPItem -Session $Session -Path $RemotePath
            if($RemoteItem.PSIsContainer)
            {
                Write-Verbose -Message "$RemotePath is a directory."
                $Null = New-Item -Path $TargetPath -ItemType Container -ErrorAction Stop
                $ChildItems = Get-FTPChildItem -Session $Session -Path $RemoteItem.FullName -Detailed
                $ChildItems | Receive-FTPItem -Session $Session -LocalPath $TargetPath -Binary $Binary -BufferSize $BufferSize                 
            }
            else
            {
                $FileSize = Get-FileSize -Session $Session -Path $RemoteItem.FullName
                Write-Verbose -Message "Found file with size: $FileSize"
                $Request = New-FTPSession -Session $Session -Path $RemoteItem.FullName -Method DownloadFile
                Write-Verbose -Message "Creating local file: $TargetPath"
                $FileStream = New-Object -TypeName IO.FileStream -ArgumentList $TargetPath, 'OpenOrCreate'
                $Response = $Request.GetResponse()
                $RequestStream = $Response.GetResponseStream()
            
                [Byte[]]$Buffer = New-Object -TypeName 'Byte[]' -ArgumentList $BufferSize
            
                $ReadData = 0
                Write-Verbose -Message ('Downloading file: {0}' -f $Request.RequestUri)
                Try
                {
                    Do {
                        Write-Progress -Activity "Downloading file: $($Request.RequestUri)" -Status 'Downloading...' -PercentComplete ([Math]::Min(100,[Math]::Round(($ReadData/$FileSize)*100))) -Id 1
                        $CurrentBuffer = $RequestStream.Read($Buffer, 0, $Buffer.Length)
                        $FileStream.Write($Buffer, 0, $CurrentBuffer)
                        $ReadData += $CurrentBuffer
                    } While ($CurrentBuffer -gt 0)
                }
                Catch
                {
                    Throw
                }
                Write-Progress -Completed -Id 1 -Activity "Downloading file: $($Request.RequestUri)"
                Write-Verbose -Message ($Request.GetResponse()).StatusDescription
            }
        }
        Catch
        {
            throw
        }
        Finally
        {
            Try
            {
                $FileStream.Close()
                $FileStream.Dispose()
                $RequestStream.Close()
                $RequestStream.Dispose()
            }
            Catch
            {
                
            }
                
        }
    }
}
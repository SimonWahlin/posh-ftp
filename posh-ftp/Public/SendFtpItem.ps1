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
        $LocalPath,

        [Parameter(Mandatory=$false)]
        [String]
        $RemotePath,
        
        [Parameter()]
        [Switch]
        $Recurse,
        
        [Parameter()]
        [Switch]
        $Force,

        [Parameter(Mandatory=$false)]
        [Bool]
        $Binary = $false,

        [Parameter(Mandatory=$false)]
        [UInt32]
        $BufferSize = 20KB
    )
    Process
    {
        if($PSBoundParameters.ContainsKey('RemotePath'))
        {
            $TargetPath = $RemotePath
        }
        else
        {
            $TargetPath = $Session.RequestUri.AbsolutePath
        }

        Try
        {
            $LocalItem = Get-Item -Path $LocalPath -ErrorAction Stop
            if($LocalItem.PSIsContainer)
            {
                New-FTPDirectory -Session $Session -Path $TargetPath -Name $LocalItem.Name -ErrorAction Stop
                if($Recurse)
                {
                    $PSBoundParameters.RemotePath = (Join-Path -Path $TargetPath -ChildPath $LocalItem.Name)
                    $Null = $PSBoundParameters.Remove('LocalPath')
                    Get-ChildItem -Path $LocalItem.FullName | Send-FTPItem @PSBoundParameters
                }
            }
            else
            {
                Try
                {
                    if((Split-Path -Path $TargetPath -Leaf) -ne $LocalItem.Name)
                    {
                        $TargetPath = Join-Path -Path $TargetPath -ChildPath $LocalItem.Name
                    }
                    try {
                        $RemoteItem =  Get-FTPItem -Session $Session -Path $TargetPath -ErrorAction Stop
                        if(-Not($Force))
                        {
                            # Target exists, handle overwrite
                            Write-Warning -Message ('File [{0}] already exists, use -Force to overwrite' -f $TargetPath)
                            return
                        }
                    }
                    catch {
                        # Target does not exist, OK to upload
                    }
                }
                Catch
                {
                    if($_.CategoryInfo.Category -eq 'ObjectNotFound')
                    {
                        # Remote item not found, make sure parent exists
                        Try
                        {
                            $RemoteItem = Get-FTPItem -Session $Session -Path (Split-Path -Path $TargetPath -Parent) -ErrorAction Stop
                        }
                        Catch
                        {
                            Write-Warning -Message "Remote path does not exist."
                            throw
                        }
                    }
                    else
                    {
                        throw
                    }
                }
                
                $Params = @{
                    Session = $Session
                    Path    = $TargetPath
                    Method  = 'UploadFile'
                    Binary  = $Binary
                }
             
                $Request = New-FTPSession @Params -Verbose
                $FileStream = [IO.File]::OpenRead($LocalItem.FullName)
                $RequestStream = $Request.GetRequestStream()
                [Byte[]]$Buffer = New-Object -TypeName 'Byte[]' -ArgumentList $BufferSize
                $ReadData = 0
                Write-Verbose -Message ('Uploading file: {0}' -f $Request.RequestUri)
                Try
                {
                    Do {
                        Write-Progress -Activity "Uploading file: $($Request.RequestUri)" -Status 'Uploading...' -PercentComplete ([Math]::Round(($ReadData/$LocalItem.Length)*100)) -Id 1
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
                if($FileStream)
                {
                    $FileStream.Close()
                    $FileStream.Dispose()
                }
                if($RequestStream)
                {
                    $RequestStream.Close()
                    $RequestStream.Dispose()
                }
            }
            Catch
            {
                Write-Warning -Message "Ignoring error:$_"   
            }
        }
    }
}
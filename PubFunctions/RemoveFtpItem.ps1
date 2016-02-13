Function Remove-FTPItem {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.Net.FtpWebRequest]
        $Session,
        
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [Alias('FullName')]
        [String]
        $Path,
        
        [Parameter(Mandatory=$false)]
        [Switch]
        $Recurse
    )
    Process
    {
        try
        {
            $Target = Get-FTPChildItem -Session $Session -Path $Path -Detailed
            if(-Not($Target) -or $Target.Name -eq (Split-Path -Path $Path -Leaf))
            {
                $RequestItem = Get-FTPItem -Session $Session -Path $Path
                if($RequestItem.PSISContainer)
                {
                    $Method = 'RemoveDirectory'
                }
                else
                {
                    $Method = 'DeleteFile'
                }
                Write-Verbose -Message ('Removing: [{0}]' -f $Path)
                $Request = $Request = New-FTPSession -Session $Session -Path $Path -Method $Method
                $FTPResponse = $Request.GetResponse()
                Write-Verbose -Message $FTPResponse.StatusDescription
            }
            else
            {
                if($Recurse)
                {
                    $null = $PSBoundParameters.Remove('Path')
                    $Target | Remove-FTPItem @PSBoundParameters
                    Remove-FTPItem @PSBoundParameters -Path $Path
                }
                else
                {
                    Write-Warning -Message ('Path: [{0}] is not empty, use -Recurse to remove recursively' -f $Path)
                }           
            }
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
}
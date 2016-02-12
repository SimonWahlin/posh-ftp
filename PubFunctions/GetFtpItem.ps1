Function Get-FTPItem {
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
        if(-Not($PSBoundParameters.ContainsKey('Path')))
        {
            $Path = $Session.RequestUri.AbsolutePath
        }
        if($Path -eq '/')
        {
            if(Test-FTPLocation -Session $Session -Path $Path)
            {
                New-Object -TypeName PSObject -Property @{
                    LastWriteTime = [datetime]::MinValue
                    PSIsContainer = Test-IsFolder -Session $Session -Path $Path
                    Length = $null
                    Name = $Path
                    FullName = $Path
                }
            } 
        }
        else
        {
            $ParentPath = Split-Path -Path $Path -Parent
            if([String]::Empty -eq $ParentPath)
            {
                $ParentPath = '/'
            }
            $ChildPath = Split-Path -Path $Path -Leaf
            if([String]::Empty -eq $ChildPath)
            {
                $ChildPath = '/'
            }
            
            $RequestItem = Get-FTPChildItem -Session $Session -Path $ParentPath -Detailed | 
                Where-Object -FilterScript {$_.Name -eq $ChildPath}
            if($RequestItem)
            {
                Write-Output -InputObject $RequestItem
            }
            else
            {
                Write-Error -Category ObjectNotFound -TargetObject $Path -Message "Path not found: $Path"
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
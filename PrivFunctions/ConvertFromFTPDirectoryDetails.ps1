Function ConvertFrom-FTPDirectoryDetails {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]
        $InputObject,
        
        [Parameter(Mandatory=$false)]
        [String]
        $Path,
        
        [Parameter(Mandatory=$false)]
        [Switch]
        $AsString  
    )
    process{
        if($AsString)
        {
            $InputObject
        }
        else
        {
            Switch -Regex ($InputObject)
            {
                '(?<timestamp>\d+-\d+-\d+\s+\d+\:\d+(AM|PM))\s+(?<type><DIR>)?\s*(?<size>\d+)?\s*(?<name>.+$)'
                {
                    New-Object -TypeName PSObject -Property @{
                        LastWriteTime = [datetime]::ParseExact(($Matches.timestamp -replace '\s+',' '),'MM-dd-yy HH:mmtt',[System.Globalization.CultureInfo]::InvariantCulture)
                        PSIsContainer = if($Matches.type -like '<DIR>'){$true}else{$false}
                        Length = $Matches.Size
                        Name = $Matches.Name
                        FullName = ('{0}/{1}'-f $Path,$Matches.Name)
                    }
                    break
                }
                '(?i)(?<permissions>[-|d|r|w|x]+)\s+(?<inodes>\d+)\s*(?<owner>\w+)?\s+(?<group>\w+)\s*(?<size>\d+)\s+(?<timestamp>\w{3}\s+\d+\s+(\d+:\d+|\d{4}))\s+(?<name>.+)$'
                {
                    Try
                    {
                        $DateTime = [datetime]::ParseExact(($Matches.timestamp -replace '\s+',' '),'MMM d HH:mm',[System.Globalization.CultureInfo]::InvariantCulture)
                    }
                    Catch
                    {
                        Try
                        {
                            $DateTime = [datetime]::ParseExact(($Matches.timestamp -replace '\s+',' '),'MMM d yyyy',[System.Globalization.CultureInfo]::InvariantCulture)
                        }
                        Catch
                        {
                            $DateTime = $null
                        }
                    }
                    new-object -TypeName PSObject -Property @{
                        LastWriteTime = $DateTime
                        PSIsContainer = if($Matches.permissions[0] -like 'd'){$true}else{$false}
                        Length = $Matches.Size
                        Name = $Matches.Name
                        FullName = ('{0}/{1}'-f $Path,$Matches.Name)
                    }
                }
                default {
                    Write-Error -Message 'Failed to parse output format, use parameter -AsString to return raw data.' -Category InvalidData -TargetObject $_
                }
            }
        }
    }
}
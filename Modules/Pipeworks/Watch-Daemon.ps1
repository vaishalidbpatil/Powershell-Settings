function Watch-Daemon
{
    <#
    .Synopsis
        Watches the output from a Daemon
    .Description
        Watches the output from a Daemon

    #>
    param(
    # The name of the daemon.  Can be either the short name or the display name.  Can include wildcards.
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
    [string]
    $Name,

    # If set, will watch the daemon's results constantly
    [Alias('Constantly')]
    [Switch]$Constant,

    # If set, will keep the results of the daemon.  Otherwise, the daemon's output will be cleared.
    [Switch]$Keep

    )

    begin {
        $watchTheseDaemons = New-Object Collections.ArrayList
    }
    process {
        $matchingDaemons = @(Get-WmiObject Win32_Service| Where-Object {$_.Name -like $name -or $_.DisplayName -like $name })
        $null = $watchTheseDaemons.AddRange($matchingDaemons)
    }
    end {
        do {
            foreach ($d in $watchTheseDaemons) {
                $subName = Get-Item $d.PathName
                $subName = $subName.Name.TrimEnd($subName.Extension)
                $outFiles = Get-ChildItem -Path ($d.PathName | Split-Path) -Filter "$subName.*.out"

                foreach ($out in $outFiles) {
                    $outFileContent = [IO.File]::ReadAllText($OUT.FullName)


                    if (-not $Keep) {
                        [IO.File]::Delete($out.FullName)
                    }
                    $outFileData = & ([ScriptBLock]::Create("data { $outFileContent }" )) | Sort-Object { $_.Timestamp -as [DateTime] }
                    
                    foreach ($ofd in $outFileData) {
                        if ($ofd.OutputType -eq 'Verbose') {
                            Write-Verbose $ofd.Message
                        } elseif ($ofd.OutputType -eq 'Debug') {
                            Write-Debug $ofd.Message
                        } elseif ($ofd.OutputType -eq 'Warning') {
                            Write-Warning $ofd.Message
                        } elseif ($ofd.outputType -eq 'Error') {
                            Write-Error $ofd.Message
                        } elseif ($ofd.OutputType -eq 'Output') {
                            if ($ofd.Output -like "@{*") {
                                $outObj = & ([ScriptBLock]::Create("data { $($ofd.Output) }"))
                                New-Object PSObject -Property $outObj
                            } else {
                                $ofd.Output
                            }
                        } elseif ($ofd.OutputType -eq 'Progress') {
                            $ofd.Remove("Timestamp")
                            $ofd.Remove("OutputType")
                            $ofd.ID = $ofd.ActivityId
                            $ofd.Remove("ActivityId")
                            $ofd.Status= $ofd.StatusDescription
                            $ofd.Remove("StatusDescription")
                            $ofd.ParentId = $ofd.ParentActivityId
                            $ofd.Remove("ParentActivityId")
                            if ($ofd.RecordType -like "*Process*") {
                                $ofd.Remove("RecordType")
                                Write-Progress @ofd
                            } else {
                                $ofd.Remove("PercentComplete")
                                Write-Progress @ofd -Completed
                            }
                            
                        }
                    }
                }
            }
        } while ($constant)
    }
} 

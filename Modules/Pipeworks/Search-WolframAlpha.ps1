function Search-WolframAlpha
{
    <#
    .Synopsis
        Searches Wolfram Alpha
    .Description
        Searches Wolfram Alpha for information on anything
    .Example
        Search-WolframAlpha -For "Micrososft" -ApiKeySetting WolframAlphaApiKey
    .Link
        Get-SecureSetting
    #>
    param(
    # The term to search for.
    [Parameter(Mandatory=$true)]
    [String]$For,
    
    # The WolframAlpha pod state to return
    [string]$PodState,
       
    # The PodID of interest
    [string]$PodId,
    
    # If set, renders output as HTML
    [Switch]$AsHtml,
    
    # If set, renders the output as input to Mathemetica
    [Switch]$AsMathematicaInput,
    
    # If set, renders the output as output to Mathemetica
    [Switch]$AsMathematicaOutput,
   
    # If set, renders the output as MathML
    [Switch]$AsMathML,
    
    # Requests information as if the user was from a specific IP
    [string]$FromIP,
    
    # Requests information as if the user was from a specific location
    [string]$Location,    

    # Returns the XML result
    [Switch]$AsXml,
    
    # The API Key
    [string]$ApiKey,
    
    # A web.config or SecureSetting containing the ApiKey
    [string]$ApiKeySetting,
    
    # If set, will run the query as a background job
    [switch]$AsJob,
    
    # If set, will always refetch the data
    [Switch]$Force         
    )
    
    begin {
        #region Setup Result Cache
        Set-StrictMode -Off
        if (-not ($script:cachedRawResults)) { 
            $script:cachedRawResults = @{}            
        }
        #endregion Setup Result Cache                 
    }
    
    
    process {
        if ($apiKey) {
            $script:WolframAlphaAPIKey = $apiKey
        }
        if ($apiKeySetting) {
            $apiKey= Get-WebConfigurationSetting -Setting $apiKeySetting 
            if (-not $apiKey) {                
                $apiKey= Get-SecureSetting -Name $apiKeySetting -ValueOnly
            }
            if ($apiKey) {
                $script:WolframAlphaAPIKey = $apiKey
            }
            
        }
        
        $psBoundParameters.ApiKey = $script:WolframAlphaAPIKey

        if ($AsJob) {
            $myDefinition = [ScriptBLock]::Create("function Search-WolframAlpha {
$(Get-Command Search-WolframAlpha | Select-Object -ExpandProperty Definition)
}
")
            $null = $psBoundParameters.Remove('AsJob')            
            $myJob= [ScriptBLock]::Create("" + {
                param([Hashtable]$parameter) 
                
            } + $myDefinition + {
                
                Search-WolframAlpha @parameter
            }) 
            
            Start-Job -ScriptBlock $myJob -ArgumentList $psBoundParameters 
            return
        }
        $script:WolframAlphaWebClient = New-Object Net.WebClient
        $queryBase = "http://api.wolframalpha.com/v2/query?"
        $queryTerm = "input=$($For.Replace(' ', '%20'))"        
        if (-not $script:WolframAlphaAPIKey) {
        }
        
        $queryAPIKey = "appid=$Script:WolframAlphaAPIKey"
        
        if ($psboundParameters.PodState) {
            $queryTerm+="&podstate=$podstate"
        }
        if ($psboundParameters.PodId) {
            $queryTerm+="&includepodid=$PodId"
        }

        $query = "${QueryBase}${QueryTerm}&${QueryAPIKey}"
        if ($AsHTML) {
            $query = "${QueryBase}${QueryTerm}&${QueryAPIKey}&format=html"
            $result = $script:WolframAlphaWebClient.DownloadString($query)
            $result
        } elseif ($AsMathematicaInput) {
            $query = "${QueryBase}${QueryTerm}&${QueryAPIKey}&format=minput"
            $result = $script:WolframAlphaWebClient.DownloadString($query)
            $result
        
        } elseif ($AsMathematicaOutput) {
            $query = "${QueryBase}${QueryTerm}&${QueryAPIKey}&format=moutput"
            $result = $script:WolframAlphaWebClient.DownloadString($query)
            $result        
        } elseif ($AsMathML) {
            $query = "${QueryBase}${QueryTerm}&${QueryAPIKey}&format=mathml"
            $result = $script:WolframAlphaWebClient.DownloadString($query)
            $result       
        } elseif ($AsXML) {
            $query = "${QueryBase}${QueryTerm}&${QueryAPIKey}"
            $result = $webClient.DownloadString($query)
            $result
        } else {
            # Turn regular XML output into a psuedo object
            $query = "${QueryBase}${QueryTerm}&${QueryAPIKey}"            
            if ($location) {
                $query += "&location=$location"
            }
            
            
            if ($fromIP) {                
                $query += "&ip=$fromIP"
            }
            $result = if ($script:CachedRawResults[$query] -and (-not $Force)) {
                $script:cachedRawResults[$query]
            } else {                
                $script:cachedRawResults[$query] = $script:WolframAlphaWebClient.DownloadString($query)
                $script:cachedRawResults[$query]
            }
            $resultError = ([xml]$result).SelectSingleNode("//error")            
            if ($resultError) {            
                Write-Error -Message $resultError.msg -ErrorId "WolframAlphaWebServiceError$($resultError.Code)"    
                return
            }
            $pods = @{}
            
                Write-Verbose "$result"
            
            $result | 
                Select-Xml //pod | 
                ForEach-Object  -Begin {
                    $psObject = New-Object PSObject
                } {        
                    $pod = $_.Node            
                    if ($pod.Id -eq 'Input') {
                        $psObject.psobject.Properties.Add(
                            (New-Object Management.Automation.PSNoteProperty "InputInterpretation","$($pod.subpod.plaintext)"
                        ))
                    }
                    
                    if ($pod.Id -ne 'Input') {
                        # Try and try and try
                        $textInPods = $pod.SubPod  |Select-Object -ExpandProperty plaintext
                        $textInPods = $textInPods -join ([Environment]::NewLine)
                        $lines = $textInPods.Split([Environment]::NewLine, [StringSplitOptions]'RemoveEmptyEntries')

                        $averageItemsPerLine = $lines | 
                            ForEach-Object {
                                $_.ToCharArray() |
                                    Where-Object {$_ -eq '|' } |
                                    Measure-Object
                            } | Measure-Object -Average -Property Count |
                            Select-Object -ExpandProperty Average
                            
                        if ($averageItemsPerLine -lt 1) {
                            if (-not $lines) {
                                $psNoteProperty = New-Object Management.Automation.PSNoteProperty $pod.Title, $pod.Subpod.img.src
                                $null = $psObject.psobject.Properties.Add($psNoteProperty)                            
                            } else {
                                $psNoteProperty = New-Object Management.Automation.PSNoteProperty $pod.Title, $lines
                                $null = $psObject.psobject.Properties.Add($psNoteProperty)                            
                            }
                            
                        } elseif ($averageItemsPerLine -ge 1 -and $averageItemsPerLine -lt 2) {
                            # It's probably a table of properties, but it could also be a result list
                            $outputObject = New-Object PSObject
                            $lastProperty = $null
                            foreach ($line in $lines) {
                                $chunks = @($line.Split('|', [StringSplitOptions]'RemoveEmptyEntries'))
                                # If it's greater than 1, treat it as a pair of values
                                
                                if ($chunks.Count -gt 1) {
                                    # Heading and value.                                    
                                    $lastProperty = $chunks[0]
                                    if ("$lastProperty".Trim()) {
                                        $value = $chunks[1] | 
                                            Where-Object {"$_".Trim() -notlike "(*)"}
                                        $outputObject | Add-Member NoteProperty $chunks[0] "$value".Trim() -Force
                                    }
                                } elseif ($chunks.Count -eq 1) {
                                    # Additional value
                                    $newValue = @($outputObject.$lastProperty) +  "$($chunks[0])".Trim()
                                    if ("$lastProperty".Trim()) {
                                        $outputObject | Add-Member NoteProperty $lastProperty $newValue -Force
                                    }
                                }
                            }
                            $psNoteProperty = New-Object Management.Automation.PSNoteProperty $pod.Title, $outputObject
                            $null = $psObject.psobject.Properties.Add($psNoteProperty)                            
                        } else {
                            # It's probably a table
                            
                            if ($lines.Count -eq 1) {
                                $itemValue, $itemSource = $lines[0] -split "[\(\)]"
                                
                                $outputObject =New-Object PSOBject |
                                    Add-Member NoteProperty Value $itemValue -PassThru | 
                                    Add-Member NoteProperty Source $itemSource -PassThru
                                $psNoteProperty = New-Object Management.Automation.PSNoteProperty $pod.Title, $outputObject    
                                $null = $psObject.psobject.Properties.Add($psNoteProperty)                            
                            } else {
                                $columns = $lines[0] -split "\|" | ForEach-Object {$_.Trim() } 
                                $rows = foreach ($l in $lines[1..($lines.Count -1)]) {    
                                    $l -split "\|" | ForEach-Object { $_.Trim() } 
                                }

                                $outputObject = 
                                    for ($i =0;$i -lt $rows.Count; $i+=$columns.Count) {
                                        $outputObject = New-Object PSObject 
                                        foreach ($n in 1..$columns.Count) {
                                            $columnName =
                                                if (-not $columns[$n -1]) {
                                                    "Name"
                                                } else {
                                                    $columns[$n -1]
                                                }
                                            $outputObject | 
                                                Add-Member NoteProperty $columnName ($rows[$i + $n - 1]) -Force
                                             
                                        }
                                        $outputObject 
                                    }
                                $psNoteProperty = New-Object Management.Automation.PSNoteProperty $pod.Title, $outputObject    
                                $null = $psObject.psobject.Properties.Add($psNoteProperty)                            
                            }
                        } 
                    }
                    
                    $pods[$pod.Id] = New-Object PSObject -Property @{
                        PodText = $pod.subpod | Select-Object -ExpandProperty plaintext -ErrorAction SilentlyContinue
                        PodImage = $pod.subpod | 
                            Select-Object -ExpandProperty img -ErrorAction SilentlyContinue |
                            Select-Object -ExpandProperty src
                        PodXml = $pod
                    }                    
                } -End {
                    $psObject.psobject.Properties.Add(
                        (New-Object Management.Automation.PSNoteProperty "OutputXml",([xml]$result)
                    ))
                    try {
                    $psObject.psObject.Properties.Add(
                        (New-Object Management.Automation.PSNoteProperty "Pods",(New-Object PSObject -Property $pods)
                    ))
                    } catch {
                    $psObject.psObject.Properties.Add(
                        (New-Object Management.Automation.PSNoteProperty "Pods", $null
                    ))    
                    }
                    $psObject.pstypenames.Clear()
                    $psObject.pstypenames.add('WolframAlphaResult')
                    $psObject
                    
                    
                }
        }
    }
}
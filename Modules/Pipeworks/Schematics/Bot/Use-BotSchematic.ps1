function Use-BotSchematic
{
    <#
    .Synopsis
        Installs a bot onto the system
    .Description
        Installs bots related to a module onto a system.



        The bot schematic's parameters are a table of command names and parameters (similar to the WebCommand section).


        Each key is the name of the command.  
        The value can be a timespan describing the frequency the command will be run

            
            'Sync-Somthing' = '00:10:00'
        
        It can also be a table of parameters to be directly provided to Start-At, such as:          

            'Start-CloudCommand' = @{
                UserTableName = 'MyUsers'
                TableName = 'MyUsers'
                Filter = "Pending eq 'True'"            
                CheckEvery = "00:01:00"
                ClearProperty = 'Pending'
            }

        Bots may also include one special value:  As, which can include a pair of SecureSetting names


            As = MyUserNameSetting, MyPasswordSetting


        If no securesetting are found matching the value in As, a setting pair will be created an a credential will be requested.  
                
    #>
    param(
    # Any parameters for the schematic
    [Parameter(Mandatory=$true,ParameterSetName='ProcessSchematic')]
    [Hashtable]$Parameter,
    
    # The pipeworks manifest, which is used to validate common parameters
    [Parameter(Mandatory=$true,ParameterSetName='ProcessSchematic')]
    [Hashtable]$Manifest,
    
    # The directory the schemtic is being deployed to
    [Parameter(Mandatory=$true,ParameterSetName='ProcessSchematic')]
    [string]$DeploymentDirectory,
    
    # The directory the schematic is being deployed from
    [Parameter(Mandatory=$true,ParameterSetName='ProcessSchematic')]
    [string]$InputDirectory,
    
    # If provided, will output the schematic parameters, including optional parameters
    [Parameter(Mandatory=$true,ParameterSetName='GetSchematicParameters')]
    [string]$GetSchematicParameter,
    
    # If set, will output the schematic's optional parameters
    [Parameter(Mandatory=$true,ParameterSetName='GetSchematicParameters')]
    [Switch]$IncludeOptional,


    # If set, will output the schematic's optional parameters
    [Parameter(Mandatory=$true,ParameterSetName='GetSchematicHelp')]    
    [Switch]$Help
    )


    begin {        
        $requiredSchematicParameters = @{
        }
         
        $optionalSchematicParameters = @{
            "BackgroundColor" = "The background color of the page"
        }
                
    }

    process {                             
        # 
        if ($psCmdlet.ParameterSetName -eq 'GetSchematicParameters') {                                    
            if ($IncludeOptional) {
                $requiredSchematicParameters  + $optionalSchematicParameters
            } else {
                $requiredSchematicParameters  
            }            
        }
        
        if ($psCmdlet.ParameterSetName -eq 'GetAllSchematicParameters') {
            return $requiredSchematicParameters                        

        }
        
        if ($psCmdlet.ParameterSetName -eq 'GetSchematicHelp') {
            $helpObj = $myInvocation.MyCommand | Get-Help           

            if ($helpObj -isnot [string]) {
                $helpObj.description[0].text 
            } 

        } 
        

        
        
        $ParameterMinusAs = @{} + $Parameter        

        $asUserSetting = ""
        $asPasswordSetting = ""
        $asProvided = $false
        if ($Parameter.As -and $Parameter.As.Count -eq 2) {
            $asProvided  = $true
            $asUserSetting, $asPasswordSetting = $Parameter.AS


            
        } else {
            

        }

        $null = $ParameterMinusAs.Remove("As")
        $asCred = $null
        foreach ($kv in $parameterMinusAs.GetEnumerator()) {
            if (-not $asProvided) {
                $asUserSetting = $kv.Key + "_Username"
                $asPasswordSetting = $kv.Key + "_Password"
            }

            $asUser = "" # Get-secureSetting $asUserSetting -ValueOnly -Type String
            $asPassword = "" #Get-secureSetting $asPasswordSetting -ValueOnly -Type String
                

            if ($asUser -and $asPassword) {
                $asCred = New-Object Management.Automation.PSCredential $asUser, (
                    ConvertTo-SecureString -AsPlainText -Force
                )
            } else {
                if (-not $asCred) {
                    $asCred = Get-Credential -Message "Bot RunAs Credentials"
                }
                
            }

            if (-not $asCred) {
                continue
            }

            if ((-not $asUser) -or (-not $asPassword)) {
#                Add-SecureSetting -Name $asUserSetting -String $asCred.UserName
#                Add-SecureSetting -Name $asPasswordSetting -String $asCred.GetNetworkCredential().Password
            }

            $startAtParams = @{}
            $startAtScript = ""

            if ($realModule) {
                $moduleList = @($realModule.RequiredModules | Select-Object -ExpandProperty Name)  + $realModule.Name
                $startAtScript += "Import-Module '$($ModuleList -join "','")' -Global" 
            }
            $startAtScript += "
$($kv.Key)"

            $startAtParams.ScriptBlock  = [ScriptBlock]::Create($startAtScript)
            if ($kv.Value -is [Hashtable]) {
                $startAtParams += $kv.Value
                $startAtParams["As"] = $asCred
                if (-not $startAtParams.Name) {
                    $startAtParams.Name = $kv.Key
                }
                

                if (-not $startAtParams.Folder) {
                    if ($realModule) {
                        $startAtParams.Folder = $realModule.Name
                    } else {
                        $startAtParams.Folder = "Bots"
                    }
                }
                Start-At @startAtParams

            } elseif ($kv.Value -as [Timespan]) {
                
                $startAtParams["As"] = $asCred
                if ($realModule) {
                    $startAtParams.Folder = $realModule.Name
                } else {
                    $startAtParams.Folder = "Bots"
                }    


                $frequency = $kv.Value -as [Timespan]
                
                $startAtParams.Name = $kv.Key + "_Now"
                Start-At @startAtParams -RepeatEvery $frequency -Now
            
                $startAtParams.Name = $kv.Key + "_Boot"
                Start-At @startAtParams -RepeatEvery $frequency -Boot 
            }


        }        
    }

} 

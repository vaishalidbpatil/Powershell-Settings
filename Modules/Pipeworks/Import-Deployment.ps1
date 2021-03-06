function Import-Deployment
{
    <#
    .Synopsis

    .Description

    #>
    [CmdletBinding(DefaultParameterSetName='AllDeployments')]
    [OutputType([Management.Automation.PSModuleInfo])]
    param(
    # The name of the deployment 
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='SpecificDeployments')]
    [string]
    $Name
    )

    begin {
        $deployments = Get-Deployment
        
        
        $loadModule = {            
            $c++
            $perc = $c * 100 / $total 
            Write-Progress "Importing Modules" $in.Name -PercentComplete $perc
            $in = $_
            $module = @(Import-Module $_.Path -PassThru -Global -Force)

            if ($module.ExportedFunctions.Keys -like "*SecureSetting*") {
                $reloadPipeworks = $true
                Import-Module Pipeworks -Force -Global
            }

            if ($module.Count -gt 1 ) {
                $module | Where-Object {$_.Name -eq $in.Name } 
            } else {
                $module
            }
        }

    }

    process {
        $reloadPipeworks = $false
        if ($PSCmdlet.ParameterSetName -eq 'AllDeployments') {
            $deploymentsToLoad = $deployments |
                Sort-Object Name
        } else {
            $deploymentsToLoad = $deployments|                
                Where-Object { $_.Name -like $name } |
                Sort-Object Name
        }
        if ($deploymentsToLoad) {
            $deploymentsToLoad |
                ForEach-Object $loadModule -Begin { $c =0; $total = @($deploymentsToLoad).Count }
        }
    }
} 

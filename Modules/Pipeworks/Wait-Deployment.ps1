function Wait-Deployment
{
    <#
    .Synopsis
        Waits for a deployment to complete
    .Description
        Waits for a deployment to Azure to complete
    #>
    param(
    # The name of the Azure service
    [Parameter(Mandatory=$true,ParameterSetName='WaitForAzureDeployment',ValueFromPipelineByPropertyName=$true)]
    [string]
    $ServiceName,

    # The slot that is being deployed.  Either Staging or Production.
    [Parameter(ParameterSetName='WaitForAzureDeployment',ValueFromPipelineByPropertyName=$true)]
    [ValidateSet("Staging","Production")]
    [string]
    $Slot = "Staging"
    )
    
    process {
        if ($PSCmdlet.ParameterSetName -eq 'WaitForAzureDeployment') {
            $progressId = Get-Random 
            $perc = 0 
            $notReady = $true
            while ($notReady) {
                $ProgressPreference = 'silentlycontinue'
                $notReady = (Get-AzureDeployment -ServiceName $ServiceName -Slot $Slot).roleInstanceList | Where-Object {
                    $_.InstanceStatus -ne 'ReadyRole'
                }
                
                $ProgressPreference = 'continue'
                $perc += 5
                if ($perc -gt 100) { 
                    $perc = 0 
                }
                Write-Progress "Waiting for Role to Start" " " -PercentComplete $perc -Id $progressId
                Start-Sleep -Seconds 1 
            }
        }        
    }
} 

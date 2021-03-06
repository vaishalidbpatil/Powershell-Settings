function Install-PSNode
{
    param(
    # The server url, ie. http://localhost:9090/
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$Server,
    
    # The command to run within the server
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]   
    [ScriptBlock]$Command,
    
    # The authentication type
    [Net.AuthenticationSchemes]
    $AuthenticationType = "Anonymous"
    )
    
    process {
       
        $safeServerName  = $Server.Replace("/", "").Replace(":","").Replace('*', 'star')
        Add-SecureSetting -Name "PSNode$safeservername" -String "$command"
        
        $port = ([uri]$server.Replace('*', 'place')).Port
        
        
        Open-Port -Port $port -Name "Port $port ForPSNode"
        
        $startScript = 
            "Import-Module Pipeworks; 
            `$command = Get-SecureSetting `"PSNode$safeservername`" -ValueOnly
            `$command = [ScriptBlock]::Create(`$command)
            Start-PSNode -Server '$server' -Command `$command -AuthenticationType '$AuthenticationType' -DoNotReturn
            "
            
        $scheduler = New-Object -ComObject Schedule.Service
        $scheduler.Connect()
        
        $task = $scheduler.NewTask(0)
        $task.Principal.RunLevel = 1
        $task.Settings.MultipleInstances = 3
        $task.Settings.RunOnlyIfNetworkAvailable = $true
        
        $action = $task.Actions.create(0)
        $action.path = "$pshome\powershell.exe"
        $base64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($startScript))
        $action.arguments = "-sta -noexit -windowstyle hidden -encodedCommand $base64 "
    
        $regtrigger = $task.Triggers.create(7)
        $logonTrigger = $task.Triggers.create(9)
        $logonTrigger.UserID = "$(whoami)"
        
        $registeredTask = $scheduler.GetFolder("").RegisterTask("PSNode-$safeservername", $task.XmlText, 6, $null, $null, 3, $null)
    }
} 

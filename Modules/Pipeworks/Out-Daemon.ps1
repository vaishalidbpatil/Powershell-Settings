function Out-Daemon
{
    <#
    .Synopsis
        Creates small services that run PowerShell on a regular basis
    .Description
        Creates small services that run PowerShell on a regular basis
    .Example
        Out-Deamon -ScriptBlock {    
            Write-Warning "Warning"
            Write-Error "Error"
            $VerbosePreference = 'continue'
            Write-Verbose "Verbose"
            $debugPreference = 'continue'
            Write-Debug "Debug"
            Write-Progress "a" "b" -PercentComplete 1
            1
            New-Object PSObject -Property @{"A" = "b";"c" = "d" }
        } -Interval "00:00:15" -Name streamtest

    #>
    param(
    # The short name of the service.  
    [Parameter(Mandatory=$true)]    
    [string]
    $Name,

    # The display name of the service.  If no displayname is provided, it will be set to the name
    [string]
    $DisplayName,

    # A list of scripts the deamon will run.
    [Parameter(Mandatory=$true)]
    [ScriptBlock[]]
    $ScriptBlock,

    # The interval the scripts will use to run.  If no interval is provided, the scripts will run constantly.
    [Timespan[]]
    $Interval,

    # Where the service will be stored. If not provided, the service will be stored in $env:AppData\PowerShellDaemons\
    [string]
    $ServicePath
    )

    process {
        $servicePath = if (-not $PSBoundParameters.ServicePath) {
            $psNodeRoot = Join-Path $env:APPDATA "PowerShellDaemons"
            if (-not (Test-Path $psNodeRoot)) {
                $null = New-Item -ItemType Directory -Path $psNodeRoot -Force
            }
            "$(Join-Path $psNodeRoot "$Name.exe")"                    
        } else {
            $servicePath
        }

        if (-not $DisplayName) {
            $DisplayName = $Name
        }


        $elapsedCode = ""
        $psDeclare = ""
        $psInit = ""
        $psRun = ""
        $psStop = ""
        $psStart = ""
        $timerDeclare = ""

        $dataHandlers = ""

        $timerInit = @"
        bool constant  = $(if (-not $psboundParameters.Interval) { "true;"} else {"false;"}) 
        $(
        $inc = 0
        for ($inc = 0; $inc -lt $scriptBLock.Count; $inc++) {
            if ($Interval -and $Interval[$inc]){
                $lastInterval = $interval[$inc]
            
            } 
            if ($lastInterval) {
            "System.Timers.Timer Timer$inc = new System.Timers.Timer();
        Timer$inc.Interval = $([uint32]$LastInterval.TotalMilliseconds);
        Timer$inc.Elapsed += new ElapsedEventHandler(Time${inc}Elapsed);
        Timer$inc.Start();
        "
                
            $elapsedCode += "
    void Time${inc}Elapsed(object sender, ElapsedEventArgs e) {
        RunScript${inc}();
    }
"
                
            }
            $psDeclare += 
            
        "PowerShell powerShellScript$inc;
        PSDataCollection<PSObject> powerShellScriptOutput$inc = new PSDataCollection<PSObject>();

    "
            
            $psInit += 
        "
        powerShellScript$inc = PowerShell.Create();
        powerShellScript$inc.Streams.Error.DataAdded += new EventHandler<DataAddedEventArgs>(Error${Inc}_DataAdded);
        powerShellScript$inc.Streams.Verbose.DataAdded += new EventHandler<DataAddedEventArgs>(Verbose${Inc}_DataAdded);
        powerShellScript$inc.Streams.Debug.DataAdded += new EventHandler<DataAddedEventArgs>(Debug${inc}_DataAdded);
        powerShellScript$inc.Streams.Warning.DataAdded += new EventHandler<DataAddedEventArgs>(Warning${inc}_DataAdded);
        powerShellScript$inc.Streams.Progress.DataAdded += new EventHandler<DataAddedEventArgs>(Progress${inc}_DataAdded);
        powerShellScriptOutput$inc.DataAdded += new EventHandler<DataAddedEventArgs>(Output${inc}_DataAdded);
        "
            $ps64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.getbytes($ScriptBlock[$inc]))
            $psRun +=         
        "
    void RunScript${inc}() {
        if (powerShellScript${inc}.InvocationStateInfo.State != PSInvocationState.Running) {
            byte[] byteArr = Convert.FromBase64String(`"$ps64`");
            string powerShellScript = Encoding.Unicode.GetString(byteArr);
            powerShellScript$inc.Commands.Clear();
            powerShellScript$inc.AddScript(powerShellScript, false);
            powerShellScript$inc.BeginInvoke<Object, PSObject>(null, powerShellScriptOutput$inc);
        } 
    }

"
            $psStop += "
            powerShellScript$inc.BeginStop(StopDone, null);
"
            $psStart += "
            RunScript${inc}();            
"
        
            $dataHandlers +=  @"
    void Debug${Inc}_DataAdded(object sender, DataAddedEventArgs e) {
        System.Diagnostics.Process process = System.Diagnostics.Process.GetCurrentProcess();

        PSDataCollection<DebugRecord> collection = sender as PSDataCollection<DebugRecord>;
        DebugRecord err = collection[e.Index];

        
        string errorText = "@{OutputType='Debug';Message='" + err.ToString().Replace("'", "''") + "';Timestamp='" + DateTime.Now.ToString("o") + "'}" + Environment.NewLine;
        string outputFile = process.MainModule.FileName.Replace(".exe", "") + ".$inc.out";
        System.IO.File.AppendAllText(outputFile,errorText);
   }

    void Warning${Inc}_DataAdded(object sender, DataAddedEventArgs e) {
        System.Diagnostics.Process process = System.Diagnostics.Process.GetCurrentProcess();

        PSDataCollection<WarningRecord> collection = sender as PSDataCollection<WarningRecord>;
        WarningRecord err = collection[e.Index];

        
        string errorText = "@{OutputType='Warning';Message='" + err.ToString().Replace("'", "''") + "';Timestamp='" + DateTime.Now.ToString("o") + "'}" + Environment.NewLine;
        string outputFile = process.MainModule.FileName.Replace(".exe", "") + ".$inc.out";
        System.IO.File.AppendAllText(outputFile,errorText);
   }

   void Verbose${Inc}_DataAdded(object sender, DataAddedEventArgs e) {
        System.Diagnostics.Process process = System.Diagnostics.Process.GetCurrentProcess();

        PSDataCollection<VerboseRecord> collection = sender as PSDataCollection<VerboseRecord>;
        VerboseRecord err = collection[e.Index];

        
        string errorText = "@{OutputType='Verbose';Message='" + err.ToString().Replace("'", "''") + "';Timestamp='" + DateTime.Now.ToString("o") + "'}" + Environment.NewLine;
        string outputFile = process.MainModule.FileName.Replace(".exe", "") + ".$inc.out";
        System.IO.File.AppendAllText(outputFile,errorText);
   }

    void Error${Inc}_DataAdded(object sender, DataAddedEventArgs e) {
        System.Diagnostics.Process process = System.Diagnostics.Process.GetCurrentProcess();

        PSDataCollection<ErrorRecord> collection = sender as PSDataCollection<ErrorRecord>;
        ErrorRecord err = collection[e.Index];

        
        string errorText = "@{OutputType='Error';Message='" + err.Exception.Message.Replace("'", "''").ToString() + "';Timestamp='" + DateTime.Now.ToString("o")+"'}" + Environment.NewLine;
        string outputFile = process.MainModule.FileName.Replace(".exe", "") + ".$inc.out";
        System.IO.File.AppendAllText(outputFile,errorText);
   }
   
   void Progress${Inc}_DataAdded(object sender, DataAddedEventArgs e) {
        System.Diagnostics.Process process = System.Diagnostics.Process.GetCurrentProcess();

        PSDataCollection<ProgressRecord> collection = sender as PSDataCollection<ProgressRecord>;
        ProgressRecord err = collection[e.Index];
       
        
        string errorText = "@{OutputType='Progress';StatusDescription='" + 
            err.StatusDescription.Replace("'", "''") + 
            "';Activity='" + err.Activity.Replace("'", "''") +
            "';ActivityId='" + err.ActivityId.ToString() +
            "';ParentActivityId='" + err.ParentActivityId.ToString() +
            "';RecordType='" + err.RecordType.ToString() +
            "';PercentComplete='" + err.PercentComplete.ToString() +
            "';Timestamp='" + DateTime.Now.ToString("o")+"'}" + Environment.NewLine;
        string outputFile = process.MainModule.FileName.Replace(".exe", "") + ".$inc.out";
        System.IO.File.AppendAllText(outputFile,errorText);
   }


   void Output${Inc}_DataAdded(object sender, DataAddedEventArgs e) {
        System.Diagnostics.Process process = System.Diagnostics.Process.GetCurrentProcess();

        PSDataCollection<PSObject> collection = sender as PSDataCollection<PSObject>;
        PSObject err = collection[e.Index];

        string objStr = (string)LanguagePrimitives.ConvertTo(err, typeof(string));

        if (objStr.StartsWith("@{")) {
            objStr = objStr.Replace(";", "';").Replace("=", "='").TrimEnd('}') + "'}";
        }

        string errorText = "@{OutputType='Output';Output='" +
            objStr.Replace("'", "''") +
            "';Timestamp='" + DateTime.Now.ToString("o")+"'}" + Environment.NewLine;
        string outputFile = process.MainModule.FileName.Replace(".exe", "") + ".$inc.out";
        System.IO.File.AppendAllText(outputFile,errorText);
   }
"@
        }
        )

"@
    $serviceCode = @"
using System;
using System.Timers;
using System.ServiceProcess;
using System.Threading;
using System.ComponentModel;
using System.Collections.Generic;
using System.Configuration.Install;
using System.Management.Automation;
using System.Text;
 
public class PSNodeService : ServiceBase
{
   
   public PSNodeService()
   {
      this.ServiceName = "$Name";
      this.CanStop = true;
      this.CanPauseAndContinue = false;
      this.AutoLog = true;
   }

      
    $psDeclare

   protected override void OnStart(string [] args)
   {
        $timerInit
        $psInit

        if (constant) {
            while (true) {
                $psStart
            }
        } else {
            $psStart
        }
        
        
   }

   $elapsedCode
   $psRun   
 
   protected override void OnStop()
   {
      $psStop
   }

   public void StopDone(IAsyncResult result) {
   
   }
 
   public static void Main()
   {
      System.ServiceProcess.ServiceBase.Run(new PSNodeService());
   }

   $dataHandlers
}
"@


        $s = $serviceCode

        $svcexists = Get-Service -Name $name -ErrorAction SilentlyContinue
        $useCred = if ($Credential) {
            @{Credential = $Credential}
        } else {
            @{}
        }
        if ($svcexists) {
            Stop-Service -Name $Name
            $svcExists = Get-WmiObject -Class Win32_Service -Filter "Name = '$Name'"
            if ($svcExists) {                
                $null = $svcExists.Delete()
                    
            }
            Add-Type -TypeDefinition $serviceCode -ReferencedAssemblies System.Management.Automation, System.ServiceProcess, System.Configuration.Install -OutputAssembly $servicePath -OutputType WindowsApplication -IgnoreWarnings
            
            $null = New-Service -Name $Name -DisplayName $DisplayName -BinaryPathName $ServicePath -StartupType Automatic @useCred
            Start-Service -Name $Name
        } else {
            Add-Type -TypeDefinition $serviceCode -ReferencedAssemblies System.Management.Automation, System.ServiceProcess, System.Configuration.Install -OutputAssembly $servicePath -OutputType WindowsApplication -IgnoreWarnings
            $null = New-Service -Name $Name -DisplayName $DisplayName -BinaryPathName $ServicePath -StartupType Automatic @useCred
            Start-Service -Name $Name
        }
    }
} 

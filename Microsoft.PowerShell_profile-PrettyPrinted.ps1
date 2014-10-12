function prompt {
  # this prompt function chops off the path to fit within 20 characters
  # $loc = Resize-Path (Get-Location)
  $loc = (Get-Location)
  $tail = ""
  if ($loc.ToString().length -lt 20) {
    $currpath = ($loc)
  } else {
    $tail = Split-Path -Leaf -Path $loc
    $currpath = $loc.ToString().Substring(0,$loc.ToString().IndexOf("\",3) + 1) + "...\" + $tail
  }

  $head = $env:COMPUTERNAME + "@" + $env:USERNAME + ": " + $currpath

  $p = $head.ToString().Replace("\","/")

  "$p $_$ "
}

function Resize-Path {
  param(
    [ValidateScript({ Test-Path $_ -PathType 'Container' })]
    [string]
    $Path
  )
  $tail = ""
  if ($Path.ToString().length -lt 20) {
    $currpath = ($Path)
  } else {
    $tail = Split-Path -Leaf -Path ($Path)
    $pathSegments = Split-Path -Parent -Path $Path.ToString().Split('\')
    $currpath = $Path.ToString().Substring(0,$Path.ToString().IndexOf("\",3) + 1) + "...\" + $tail
  }

}
<#
function prompt { 
	$p = $loc.ToString().substring(0,$loc.ToString().IndexOf("\",3)+1)+"...\"+$tail.Replace("\","/") 
	"$p>" 
}

# put your logic here for getting prompt color by machine name
function GetMachineColor($computerName)
{
   [ConsoleColor]::Green
}

# put your logic here for getting prompt color by machine name
function GetUserColor($userName)
{
   [ConsoleColor]::Magenta
}

function GetComputerName
{
  # if you want FQDN
  # $ipProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
  # "{0}.{1}" -f $ipProperties.HostName, $ipProperties.DomainName

  # if you want host name only
  $env:computername
}

function prompt
{
  $cn = GetComputerName

  # write computer name with color
  Write-Host "[${cn}]:~" -Fore (GetMachineColor $cn) -NoNew

  $un = $env:username
  Write-Host "${un} " -Fore (GetUserColor $un) -NoNew

  # generate regular prompt you would be showing
  $defaultPrompt = "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "

  # generate backspaces to cover [computername]: pre-prompt printed by powershell
  $backspaces = "`b" * ($cn.Length + 4) + "`b" * ($un.Length + 4)

  # compute how much extra, if any, needs to be cleaned up at the end
  $remainingChars = [Math]::Max(($cn.Length + 4) - $defaultPrompt.Length, 0)
  $tail = (" " * $remainingChars) + ("`b" * $remainingChars)

  "${backspaces}${defaultPrompt}$_${tail}"
}
#>

function Set-EmptyFile {
  param([Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$targetFile)

  <# Set-Content -Path ($args[0]) -Value ($null) #>
  if (Test-Path ($targetFile)) {
    Set-Timestamp $targetFile
  } else {
    New-Item -ItemType file $targetFile
  }
}

function Set-Timestamp {
  <# To update the timestamp of a file: #>
  ($args[0]).LastWriteTime = Get-Date
}

<#
    .Synopsis
        Sets location to the first parent directory that whose name starts with the given target dir.
    .Description
        Searches upwards to the root drive.
        If target dir is not found, a message is emitted to the console
    .Example
        cd c:\user\joeshmoe\Documents 
        C:\user\joeshmoe\Documents>
        Set-LocationTo us 
        C:\user>
#>

function Set-LocationTo {
  param([Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$targetDir)

  $dirs = (pwd).Path.Split('\')
  for ($i = $dirs.length - 1; $i -ge 0; $i --) {
    if ($dirs[$i].ToLower().StartsWith($targetDir.ToLower())) {
      $targetIndex = $i
      break
    }
  }
  if ($targetIndex -eq 0) {
    Write-Host "Unable to resolve $targetDir"
    return
  }

  $targetPath = ''
  for ($i = 0; $i -le $targetIndex; $i++) {
    $targetPath += $dirs[$i] + '\'
  }

  Set-Location $targetPath
}
<#
.. # goes to parent folder
 .. Foo # goes to sibling folder named ‘Foo’
#>

function GoUp (h) {
) {
  Set-Location -Path $path"
}

}
function GoUpUp (h) {
) {
  Set-Location -Path ..\$path"
}

}
function GoHome (h) {
) {
  Set-Location -Path v:HOME\$path"
}

}

function Get-DirSize
{
  param()
 )
  es = 0 = 0
  nt = 0 = 0

  Get-ChildItem  | F | ForEach-Object {
    if (is -is [System.IO.FileInfo])
    {
      es +=  += en.length
      nt++
++
    }
  }

  Write-Host    " -No -NoNewline

  if (es -ge -ge 1KB -and es -lt -lt 1MB)
  {
    Write-Host ( [ + [math]::Round((es / 1 / 1KB),2) + ") -F) -ForegroundColor te" -No -NoNewline
  }
  elseif (es -ge -ge 1MB -and es -lt -lt 1GB)
  {
    Write-Host ( [ + [math]::Round((es / 1 / 1MB),2) + ") -F) -ForegroundColor te" -No -NoNewline
  }
  elseif (es -ge -ge 1GB)
  {
    Write-Host ( [ + [math]::Round((es / 1 / 1GB),2) + ") -F) -ForegroundColor te" -No -NoNewline
  }
  else
  {
    Write-Host ( $ + es + " + tes") -F) -ForegroundColor te" -No -NoNewline
  }
  Write-Host  " -No -NoNewline
  Write-Host nt -Fo -ForegroundColor te" -No -NoNewline
  Write-Host les"



}

function Get-DirWithSize
{
  param()
 )
  Get-ChildItem 
  
  Get-DirSize 
}

}

# git related functions and aliases
function get-gitbranch { git ch }
 }
function get-gitbranchall { git ch -a  -a }
function get-gitconfiglist { git ig -l  -l }
function get-gitlog { git }
 }
function get-gitlogpretty { git retty }
 }
function get-gitlogplaintext { git laintext }
 }
function get-gitlogalt { git lt }
 }
function get-gitstash { git h -l  -l }
function get-gitstatus2 { git us }
 }
function get-gitsvnfetch { git fet h }
 }
function get-gitsvnrebase { git reb se }
 }
function get-gitsvndcommit { git dco mit }
 }

####################################
# end of functions
####################################
# start of initialization code
####################################

## Set the profile directory first, so we can refer to it from now on.
# Set-Variable ProfileDir = (Split-Path -Parent $MyInvocation.MyCommand.Path) -Option AllScope
Set-Variable ileDir (Sp (Split-Path -Parent nvocation.MyC.MyCommand.Path) -Option cope
##
## Set the script directory
Set-Variable ptDir (Sp (Split-Path -Parent nvocation.MyC.MyCommand.Path) -Option cope



:cdpath = " = v:HOME\Downloads\_Categories\;c:\dev;$env:HOME\Downloads"
$e
:Path +=  += Split-Path $PROFILE);$env:HOME\Downloads\_Categories\PowerShell" 
#
## I add my "Scripts" directory and all of its direct subfolders to my PATH
:Path +=  += Split-Path $PROFILE)\Scripts"
#$
#$env:Path = Get-ChildItem $ProfileDir\Script[s],$ProfileDir\Scripts\* | 
#               Where-Object { $_.PsIsContainer } | 
#               ForEach-Object { $_.FullName } | 
#               Join ";" -append $ENV:PATH -unique

# dot source the directory jumper and file dir/ls colorizer
.v:HOME\Documents\WindowsPowerShell\posz.ps1"
. 
.v:HOME\Documents\WindowsPowerShell\git-dir.ps1"



# set the aliases that we like
Set-Alias -Name  -Va -Value Set-LocationTo
Set-Alias -Name h -Va -Value Set-EmptyFile
Set-Alias -Name  -Va -Value Program Files\Sublime Text 3\sublime_text.exe"
Se
Set-Alias -Name a -Value pad.exe
Se
Set-Alias -Name -Va -Value Program Files (x86)\Notepad++\notepad++.exe" 
<
<#Set-Alias -Name man -Value less.exe#>
Set-Alias -Name  -Va -Value GoUp
Set-Alias -Name ." -Va -Value GoUp
Set-Alias -Name " -Va -Value GoUpUp
Set-Alias -Name  -Va -Value GoHome
Set-Alias -Name Va -Value Edit-DTWCleanScript

Set-Alias -Name a -Value exe
Se
Set-Alias -Name Va -Value get-gitbranch
Set-Alias -Name -Va -Value get-gitbranchall
Set-Alias -Name -Va -Value get-gitconfiglist
Set-Alias -Name -Va -Value get-gitlog
Set-Alias -Name  -Va -Value get-gitlogpretty
Set-Alias -Name  -Va -Value get-gitlogplaintext
Set-Alias -Name  -Va -Value get-gitlogalt
Set-Alias -Name Va -Value get-gitstatus2
Set-Alias -Name -Va -Value get-gitstash
Set-Alias -Name f -Va -Value get-gitsvnfetch
Set-Alias -Name r -Va -Value get-gitsvnrebase
Set-Alias -Name c -Va -Value get-gitsvndcommit

## I determine which modules to pre-load here (in this SIGNED script)
oModules = ' = et', 'P,hCode', 'P,X', 'D,.PS.PrettyPrinterV1.psd1'
##
## 'Autoload', 'Authenticode', 'HttpRest', 'Strings', 'ResolveAliases', 'PowerTab', 'sqlps', 
###################################################################################################
## Preload all the modules in AutoModules, printing out their names in color based on status
## No errors while loading modules (I will save them and print them out later)
orActionPreference = " = entlyContinue"
Wr
Write-Host ding Modules: " -Fo -Fore  -No -NoNewline
oRunErrors = @ = @()
foreach (ule in  in oModules ) {) {
  Import-Module ule -EA -EA ntlyContinue -EV -EV ipt:AutoRunErrors
  
  if ({ ) {
    Write-Host dule " -fo -Fore  -No -NoNewline
  } else {
    Write-Host dule " -fo -Fore -No -NoNewline
  }
}
###################################################################################################

Write-Host
orActionPreference = " = tinue"
# 
# Write out the error messages if we missed loading any modules
if (oRunErrors) { ) { oRunErrors | O | Out-String | Write-Host -Fore }
 }

<#
Import-Module PsGet
Import-Module pssql
# Import-Module PSCX
Import-Module "C:\Users\jr286576\Documents\WindowsPowerShell\Modules\DTW.PS.PrettyPrinterV1.psd1"
Import-Module DTW.PS.FileSystem.Encoding.psm1
Import-Module DTW.PS.PrettyPrinterV1.psm1
#>

# Load posh-git example profile
.v:HOME\Documents\Github\posh-git\profile.example.ps1'



# dot source the new-command-wrapper
#. 'C:\Users\jr286576\Documents\WindowsPowerShell\Scripts\New-CommandWrapper.ps1'

Remove-Item s:dir
Re
Remove-Item s:ls
Se
Set-Alias Get-DirWithSize Get-DirWithSize
Set-Alias et Get-DirWithSize

#
Set-Alias -Name -Va -Value Write-Color-LS

# start a transcript session
pDate = G = Get-Date
nscriptFile = " = v:HOME\Documents\WindowsPowershell\Transcripts\PoshTranscript" `
 `
   + pDate.Yea.Year + pDate.Mon.Month.ToString() + ) + pDate.Day.Day.ToString()
i)
if (Test-Path (nscriptFile+".t + t")) {)) {
   = 0 = 0
  do {  ++ ++ } while (Test-Path (nscriptFile+"-" + $ct + .ToS.ToString()+".) + t") )
))
  # $ctr++
  nscriptFile +=  += $ct + .ToS.ToString()+".) + t" 
}
} else {
  nscriptFile +=  += t" 
}
}
nscript will be started in: $TranscriptFile"
St
Start-Transcript nscriptFile | O | Out-Null

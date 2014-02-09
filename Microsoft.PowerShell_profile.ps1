function prompt {
    # $loc = Resize-Path (Get-Location)
    $loc = (Get-Location)
    $tail = ""
    if($loc.ToString().length -lt 20) {
      $currpath = ($loc)
    } else {
      $tail = Split-Path -leaf -path $loc
      $currpath = $loc.ToString().substring(0,$loc.ToString().IndexOf("\",3)+1) + "...\" + $tail
    }

		$head = $env:COMPUTERNAME + "@" + $env:USERNAME + ": " + $currpath

		$p = $head.ToString().Replace("\","/")
    
    "$p $_$ "
}

function Resize-Path {
  Param( 
          [ValidateScript({Test-Path $_ -PathType 'Container'})] 
          [string] 
          $Path 
  ) 
  $tail = ""
  if($Path.ToString().length -lt 20) {
    $currpath = ($Path)
  } else {
    $tail = Split-Path -leaf -path ($Path)
    $pathSegments = Split-Path -parent -path $Path.ToString().Split('\')
    $currpath = $Path.ToString().substring(0,$Path.ToString().IndexOf("\",3)+1) + "...\" + $tail
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
    <# Set-Content -Path ($args[0]) -Value ($null) #>
    New-Item -ItemType file example.txt
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
    param(  [parameter(Mandatory = $true)]            
         [ValidateNotNullOrEmpty()]            
            [string] $targetDir)            
            
    $dirs = (pwd).Path.Split('\')            
    for($i = $dirs.Length - 1; $i -ge 0; $i--) {            
        if ($dirs[$i].ToLower().StartsWith($targetDir.ToLower())) {            
            $targetIndex = $i            
            break            
        }            
    }            
    if($targetIndex -eq 0) {             
        Write-Host "Unable to resolve $targetDir"             
        return            
    }            
            
    $targetPath = ''            
    for($i = 0; $i -le $targetIndex; $i++) {            
       $targetPath += $dirs[$i] + '\'             
    }            
            
    Set-Location $targetPath            
}            
<#
.. # goes to parent folder
 .. Foo # goes to sibling folder named ‘Foo’
#>

function GoUp($path) {
    Set-Location -path "..\$path"
}

function GoUpUp($path) {
    Set-Location -path "..\..\$path"
}
function GoHome($path) {
    Set-Location -path "$home\$path"
}

$env:cdpath = "C:\users\jr286576\Downloads\_Categories\;c:\dev;C:\users\jr286576\Downloads"
$env:path += ";C:\users\jr286576\Documents\WindowsPowerShell;C:\users\jr286576\Downloads\_Categories\PowerShell" 

# dot source the directory jumper
. c:\Users\jr286576\Documents\WindowsPowerShell\posz.ps1

# set the aliases that we like
Set-Alias -Name cdto -Value Set-LocationTo
Set-Alias -Name touch -Value Set-EmptyFile
Set-Alias -Name subl -Value "C:\Program Files\Sublime Text 3\sublime_text.exe"
Set-Alias -name n -Value notepad.exe
Set-Alias -name npp -Value "C:\Program Files (x86)\Notepad++\notepad++.exe" 
<#Set-Alias -Name man -Value less.exe#>
Set-Alias -Name ".." -Value GoUp 
Set-Alias -Name "cd.." -Value GoUp
Set-Alias -Name "..." -Value GoUpUp
Set-Alias -Name home -Value GoHome
Set-Alias -Name pp -Value DTW.PS.PrettyPrinterV1 

#git related functions and aliases
function get-gitbranch { git branch }
function get-gitbranchall { git branch -a }
function get-gitconfiglist { git config -l }
function get-gitlog { git log }
function get-gitlogpretty { git lg-pretty }
function get-gitlogplaintext { git lg-plaintext }
function get-gitlogalt { git lg-alt }
function get-gitstash { git stash -l }
function get-gitstatus2 { git status }
function get-gitsvnfetch { git svn fetch }
function get-gitsvnrebase { git svn rebase }
function get-gitsvndcommit { git svn dcommit }

set-Alias -Name g -Value Git.exe
set-Alias -Name gb -Value get-gitbranch
set-Alias -Name gba -Value get-gitbranchall
set-Alias -Name gcl -Value get-gitconfiglist 
set-Alias -Name glg -Value get-gitlog
set-Alias -Name glgp -Value get-gitlogpretty
set-Alias -Name glgt -Value get-gitlogplaintext
set-Alias -Name glga -Value get-gitlogalt
set-Alias -Name gs -Value get-gitstatus2
set-Alias -Name gst -Value get-gitstash
set-Alias -Name gsvnf -Value get-gitsvnfetch
set-Alias -Name gsvnr -Value get-gitsvnrebase
set-Alias -Name gsvnc -Value get-gitsvndcommit

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Import-Module PsGet
# Import-Module PSCX
Import-Module "C:\Users\jr286576\Documents\WindowsPowerShell\Modules\DTW.PS.PrettyPrinterV1.psd1"
<#Import-Module DTW.PS.FileSystem.Encoding.psm1
Import-Module DTW.PS.PrettyPrinterV1.psm1#>

# Load posh-git example profile
. 'C:\Dev\posh-git\profile.example.ps1'

#start a transcript session
$TempDate = Get-Date
$TranscriptFile = "C:\Users\JR286576\Documents\WindowsPowershell\Transcripts\PoshTranscript" `
                  + $TempDate.Year + $TempDate.Month.ToString("00") + $TempDate.Day.ToString("00")
if (Test-Path $TranscriptFile+".txt") {
  $ctr = 0
  do { $ctr ++ } while ( Test-Path ($TranscriptFile+"-"+$ctr.ToString("00")+".txt") )
  # $ctr++
  $TranscriptFile += "-"+$ctr.ToString("00")+".txt" 
} else {
  $TranscriptFile += ".txt" 
}
echo "Transcript will be started in: $TranscriptFile"
Start-Transcript $TranscriptFile >> null
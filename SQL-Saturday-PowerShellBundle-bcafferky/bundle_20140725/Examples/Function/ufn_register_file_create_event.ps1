# Author:  Bryan Cafferky      Date:  2013-11-14
# 
# Purpose:  Move a file from one folder to another.
#
#

# E:\Powershell\Function\ufn_prepare_eligibility_file_for_load.ps1

function ufn_register_file_create_event([string] $source, [string] $filter)
{


   try
   {
     Write-Host "Watching $source for new files..."
     $fsw = New-Object IO.FileSystemWatcher $source, $filter -Property @{IncludeSubdirectories = $false; NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'}
     Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
     write-host "Your file has arrived."   }
    }
   catch
    {
      "Error registring file creae event."
    }

} 


# ufn_register_file_create_event $source $filter  

# Unregister-Event FileCreated 
# Author:  Bryan Cafferky      Date:  2013-11-29
# 
# Purpose:  Adds text to every line in a text file...
#
# Taken from internet at: http://stackoverflow.com/questions/4952535/add-text-to-every-line-in-text-file-using-powershell
#
#

function ufn_file_rows_append_text ([string] $extratxt) 
 { 
  process{
   foreach-object {$_ + $extratxt}
    } 
  }

<#
$a = Get-Content "C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\SQL_Servertst.ps1"
$a | ufn_file_rows_append_text "&" > "C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\SQL_Servertstout.ps1"
#>

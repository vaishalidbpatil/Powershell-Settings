
<#
Author:  Bryan Cafferky    2013-12-15

Pupose:  Wait for file to be placed in a folder so it can be loaded.

#>

. C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Function\ufn_register_file_create_event.ps1
. C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\function\ufn_say_it.ps1

$source = 'C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\'
$filter = '*.*'
$destination = 'E:\Data\CHI\Process\Eligibility\'

 ufn_register_file_create_event $source $filter  
 
 # Unregister-Event FileCreated
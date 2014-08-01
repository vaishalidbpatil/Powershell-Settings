<#
Author:  Bryan Cafferky  2013-12-09

Purpose:  Combine multiple input files into one file and add column header so Informatica can load.

#>

# Load the functions...
. C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Function\ufn_combine_files

ufn_combine_files 'C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data' 'C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\combined.txt' 'o*.txt' -Verbose


#  Author:  Bryan Cafferky   2013-12-15
#
# Purpose:  Use a function to wait for a given file to appear in a folder we specify.
#
#     

#  Use the dot notation to get the function loaded into memory...
. C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\function\ufn_wait_for_file.ps1

# Wait for file...

ufn_wait_for_file 'C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\' 'filetowaitfor.txt'



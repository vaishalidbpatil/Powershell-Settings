# Author:  Bryan Cafferky      Date:  2013-11-29
# 
# Purpose:  For loads of FTPed files.  Wait for the file to arrive...
#
#

function ufn_wait_for_file([string] $path, [string] $file)
{ 

$theFile = $path + $file
 
#  $theFile variable will contain the path with file name of the file we are waiting for.
While (1 -eq 1) {
    Write-Host $theFile
    IF (Test-Path $theFile) {
        #file exists. break loop
        break
    }
    #sleep for 2 seconds, then check again - change this to fit your needs...
    Start-Sleep -s 2
}
Write-Host 'File found.'
}

# Example call below...
# ufn_wait_for_file 'C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\' 'filecheck.txt' 
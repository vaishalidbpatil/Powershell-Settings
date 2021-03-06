<#   Author:  Bryan Cafferky    2013-12-10

     Purpose:  Copy files from source to target.
     
#>     
# Function to copy newest file of a patern...
    function ufn_copy_newest_file {
        [CmdletBinding()]
        param (
            [string]$sourcepath,
            [string]$targetpath,
            [string]$filefilter,
            [switch]$isdeletesource
          )
          
          [string] $pathandfile = $sourcepath + $filefilter
          
          # gci C:\temp\*.* | sort LastWriteTime -desc | select -first 1 | cpi -dest C:\DropBox\Dropbox
          
       Get-ChildItem $pathandfile | sort LastWriteTime -desc | select -first 1 | Copy-Item -Destination $targetpath 
                
               
          }
          
    # Example Call:
          
    #  ufn_copy_newest_file "C:\Users\BryanCafferky\Documents\data\" "C:\Users\BryanCafferky\Documents\data\copy"  "*.accdb"       
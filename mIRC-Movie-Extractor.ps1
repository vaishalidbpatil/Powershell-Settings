## from http://superuser.com/questions/620056/recursively-unzip-files-where-they-reside-then-delete-the-archives
Param(
   [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
   [Alias("FolderPath","LiteralPath","Path")]
   [string[]]
   $filePath
)
## $filePath="X:\Test";
# Write-Debug $filePath

Get-ChildItem $filePath -recurse | %{ 

    if ($_.Name -match "^*.`.tar$")
    {
		$extractDir = $($_.Name) -replace "$($_.Extension)$", ""
		# Write-Host $($_.FullName)
		# Write-Host $($_.Name)
		# Write-Host $($_.Extension)
		# Write-Host $extractDir
        # Write-Host "-".PadRight($($_.FullName).Length, "-")
        Write-Debug "-".PadRight($($_.FullName).Length, "-")        
 
        $parent = "$(Split-Path $_.FullName -Parent)";    
        Write-Host "Extracting $($_.FullName) to $parent"
		Write-Debug "Extracting $($_.FullName) to $parent"
		
        $arguments = @("x", "`"$($_.FullName)`""); # , "-o`"$($parent)`""
        # Write-Host $arguments
        $ex = Start-Process -FilePath "`"C:\Program Files\7-Zip\7z.exe`"" -ArgumentList $arguments -wait -PassThru;

        if ($ex.ExitCode -eq 0)
        {
			# Write-Host "Extraction successful, deleting $($_.FullName)"
			Write-Debug "Extraction successful, deleting $($_.FullName)"
			Set-Location $extractDir
			Write-Host "$parent\$extractDir"
			$sfvcheck = Start-Process "cmd.exe" "/c C:\Util\cfv.bat" `
                                        -WorkingDirectory "$parent\$extractDir" `
                                        -wait -PassThru -NoNewWindow;
			# $sfvcheck = Start-Process -FilePath "`"C:\Program Files\TeraCopy\TeraCopy.exe`"" -ArgumentList $arguments -wait -PassThru;
			if ($sfvcheck.ExitCode -eq 0)
			{
				# Write-Host "SFV Check succeeded, extracting video"
				Write-Debug "SFV Check succeeded, extracting video"
                
                $arguments2 = @("e", "*.rar");
                # Write-Host $arguments2
                $ex2 = Start-Process -FilePath "`"C:\Program Files\7-Zip\7z.exe`"" -ArgumentList $arguments2 -wait -PassThru;

                if ($ex2.ExitCode -eq 0)
                {
                    # Delete the extracted source files
                    $filesToKill = @("*.r??", "*sample*.*", "*.sfv")
                    Remove-Item $filesToKill
                    Set-Location ..
                    Remove-Item $_.FullName -Force
                    # Write-Host "Original item deleted"
                    # rmdir -Path $_.FullName -Force
				}
			} else {
                Set-Location ..
                "Error extracting $($_.FullName)" | Out-File -FilePath "mIRC-M-E.Log" -Append
			}
        } else {
            Write-Host "Aborted with exit code: " $ex.ExitCode.ToString()
		}
	}
}
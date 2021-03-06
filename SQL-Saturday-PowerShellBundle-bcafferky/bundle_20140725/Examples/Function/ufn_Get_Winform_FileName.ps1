Function ufn_Get_Winform_FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

function Set-OutputPaneColor {
param
(
    [parameter(Mandatory=$true,ValueFromPipeline=$true)]
    $color
)
    $psise.Options.OutputPaneBackground = $color
    $psise.Options.OutputPaneTextBackground = $color
}

function Set-CommandBackPaneColor {
param
(
    [parameter(Mandatory=$true,ValueFromPipeline=$true)]
    $color
)
    $psise.Options.CommandPaneBackground = $color
}

Function ufn_Get_Winform_GetColor($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $colorDialog = new-object System.Windows.Forms.ColorDialog 
    $colorDialog.AllowFullOpen = $true
    $colorDialog.ShowHelp = $true
    $colorDialog.ShowDialog()  | Out-Null
    $colorDialog.Color.Name
} #end function Get-FileName

# Example Call:
#
#  File Picker Common Dialog...
#  ufn_Get_Winform_FileName "C:\windows\"

# [void]$psISE.CustomMenu.Submenus.Add("Output Pane Color", {Get-Color | Set-OutputPaneColor},$null)
#  ufn_Get_Winform_GetColor
  
#  write-host "This color is cool!" -foregroundcolor (ufn_Get_Winform_GetColor)
  
  
  # | Set-CommandBackPaneColor
[void] [Reflection.Assembly]::LoadWithPartialName( 'System.Windows.Forms' )

$ofn = New-Object System.Windows.Forms.OpenFileDialog

$outer = New-Object System.Windows.Forms.Form
$outer.StartPosition = [Windows.Forms.FormStartPosition] "Manual"
$outer.Location = New-Object System.Drawing.Point -100, -100
$outer.Size = New-Object System.Drawing.Size 10, 10
$outer.add_Shown( { 
   $outer.Activate();
   $outer.DialogResult = $ofn.ShowDialog( $outer );
   $outer.Close();
 } )
$outer.ShowDialog()
$outer.DialogResult.Filename
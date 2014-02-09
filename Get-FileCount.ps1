$cmd = cmd /c dir .\ /b /s /ad
$gci = gci -recurse -directory .\ | select -ExpandProperty fullname
 
Compare-Object $cmd $gci
echo ($cmd).count
echo ($gci).count
## get-content $gci
$gci
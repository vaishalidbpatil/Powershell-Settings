$randomDatabasePath =  Join-Path $env:Temp "$(Get-Random).sdf"
$dbName = Get-Random

New-SQLDatabase -DatabasePath $randomDatabasePath -UseSqlCompact

#Add-SqlTable -DatabasePath $randomDatabasePath -UseSqlCompact -TableName "TestTable" -Column a,b -KeyType Sequential -DataType integer, integer

$inputObjs = @()
$inputObjs += New-Object PSObject -Property @{
    "a" = Get-Random
    "B" = Get-Random
} 
$o = New-Object PSObject -Property @{
    "a" = Get-Random
    "B" = Get-Random
}
$o.pstypenames.clear()
$o.pstypenames.add('a')
$inputObjs += $o 
$inputObjs |
    Update-Sql -UseSqlCompact -DatabasePath $randomDatabasePath -TableName "TestTable" -Force 

$dbobjs = Select-SQL -FromTable TestTable -UseSqlCompact -DatabasePath $randomDatabasePath 
$dbobjs |
    Add-Member NoteProperty B (Get-Random) -Force -PassThru |
    Update-Sql -UseSqlCompact -DatabasePath $randomDatabasePath -TableName "TestTable" -Force 


Select-SQL -FromTable TestTable -UseSqlCompact -DatabasePath $randomDatabasePath 

Remove-SQL -TableName TestTable -UseSQLCompact -DatabasePath $randomDatabasePath  

#Remove-Item -Path $randomDatabasePath 

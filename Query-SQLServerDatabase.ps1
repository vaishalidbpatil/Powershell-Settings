# copied from https://github.com/IrisClasson/PowerShell_General/blob/master/sql.ps1
# and http://irisclasson.com/2013/10/16/how-do-i-query-a-sql-server-db-using-powershell-and-how-do-i-filter-format-and-output-to-a-file-stupid-question-251-255/
$dataSource = "localhost"
# $user = "user"
# $pwd = "1234"
$database = "Jay"
# uid=$user; pwd=$pwd;
$connectionString = "Server=$dataSource;Database=$database;Integrated Security=True;"
$query = "select * from Demos"

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
#$connection.ConnectionString = "Server=$dataSource;Database=$database;Integrated Security=True;"
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText  = $query

$result = $command.ExecuteReader()

$table = new-object "System.Data.DataTable"
$table.Load($result)

# $format = @{Expression={$_.Id};Label="User Id";width=10},@{Expression={$_.Name};Label="Identified Swede"; width=30}
$format = @{Expression={$_.cBand.Trim()};Label="Band Name";width=30}, `
			@{Expression={$_.cTitle.Trim()};Label="Demo Title"; width=45}, `
			@{Expression={$_.cDate};Label="Date"; width=10}

# $table | Where-Object {$_.cCountryID -eq "000000007" -and $_.cDate -lt 1990} `
# 		| format-table $format

# $table | Get-Member
# @{Expression="cBand";Descending=$false}, @{Expression="cDate";Descending=$true}

$table | Where-Object {$_.cCountryID -eq "000000007" -and $_.cDate -lt 1990} `
	| sort-object -Property cBand `
	| format-table $format `
	| Out-File C:\Users\jr286576\Documents\WindowsPowerShell\SwedishBands.txt

$connection.Close()
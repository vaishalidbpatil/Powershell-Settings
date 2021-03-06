# Author:  Michael Sorens 
# 
# Found at: 
#    https://www.simple-talk.com/sql/database-administration/practical-powershell-for-sql-server-developers-and-dbas-%E2%80%93-part-1/

function ufn_Out_SqlGrid(
    [string]$query,
    [string]$title=$query,
    [string]$ServerInstance=".\sqlexpress",
    [string]$Database="master"
    )
{
    Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $query | Out-GridView -Title $title
} 

#  Out-SqlGrid "select * from sys.tables" 
<#

  Calling code written by Chad Miller
  Link: http://blogs.technet.com/b/heyscriptingguy/archive/2011/11/28/four-easy-ways-to-import-csv-files-to-sql-server-with-powershell.aspx


  Dynamically create and load a SQL Server table from a CSV file.
  
#>

$logQuery = new-object -ComObject "MSUtil.LogQuery"

$inputFormat = new-object -comobject "MSUtil.LogQuery.CSVInputFormat"

$outputFormat = new-object -comobject "MSUtil.LogQuery.SQLOutputFormat"

$outputFormat.server = "localhost"

$outputFormat.database = "adventureworks"

$outputFormat.driver = "SQL Server"

$outputFormat.createTable = $true

$query = "SELECT [BusinessEntityID]
      ,[PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
      ,[EmailPromotion]
      ,[AdditionalContactInfo]
      ,[Demographics]
           INTO dbo.MyPersonStuff2 FROM C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\PersonData.txt"

$null = $logQuery.ExecuteBatch($query,$inputFormat,$outputFormat)
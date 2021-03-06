#-------------------------------------------------------------------------------------------------#&
# PowerShell for Devs Using the SQL Provider                                                      #&
#-------------------------------------------------------------------------------------------------#&
&
  # Before we begin, load up the provider and SMO&
  . 'C:\PS\03 - SQL\02 - Load the Provider and SMO.ps1'&
&
&
  #-----------------------------------------------------------------------------------------------#&
  # Create a database with the Provider&
  #-----------------------------------------------------------------------------------------------#&
&
  Get-ChildItem SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases |&
    Select-Object -Property Name, Status, RecoveryModel, Owner |&
    Format-Table -Autosize&
&
  # Create the database -- Can go simple:&
  $dbcmd = "Create Database PSTest1"&
&
  # ...or more complex&
  $dbcmd = @"&
    CREATE DATABASE [PSTest1] CONTAINMENT = NONE ON  PRIMARY &
      ( NAME = N'PSTest1'&
      , FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\PSTest1.mdf' &
      , SIZE = 3136KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB &
      )&
      LOG ON &
      ( NAME = N'PSTest1_log'&
      , FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\PSTest1_log.ldf' &
      , SIZE = 784KB , MAXSIZE = 2048GB , FILEGROWTH = 10%&
      )&
"@&
&
  Invoke-Sqlcmd -Query $dbcmd -ServerInstance $env:COMPUTERNAME\SQL2012 &
  Get-ChildItem SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases |&
    Select-Object -Property Name, Status, RecoveryModel, Owner |&
    Format-Table -Autosize&
&
  # Move to the database folder&
  Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases\PSTest1&
  Get-ChildItem &
&
  # Now shift to the tables and list them&
  Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases\PSTest1\Tables&
  Get-ChildItem &
  &
  # If working with a particular database a lot, consider&
  # setting up a new alias to it&
  New-PSDrive -Name PST1 `&
              -PSProvider SQLSERVER `&
              -Root SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases\PSTest1&
&
  Set-Location PST1:&
  Get-ChildItem&
  &
  Set-Location PST1:\Tables&
  Get-ChildItem&
  &
  # When done, either use the remove cmdlet below, otherwise&
  # when this session ends so does the lifespan of the PSDrive&
  # Make sure to set your location outside the PSDrive first&
  Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases\PSTest1&
  Remove-PSDrive PST1&
&
&
&
&
##&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
  &
&
  #-----------------------------------------------------------------------------------------------#&
  # Create a table&
  #-----------------------------------------------------------------------------------------------#&
  $dbloc = "SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases\PSTest1"&
  Set-Location $dbloc&
&
  $dbcmd = @"&
    CREATE TABLE dbo.SqlSaturday&
    (&
        SqlSaturdayID INT NOT NULL &
      , Organizer     NVARCHAR(100)&
      , Location      NVARCHAR(100)&
      , EventDate     DATE&
      , Attendees     INT&
    )&
"@&
&
  # We can invoke like this since our current location is in a database&
  Invoke-Sqlcmd -Query $dbcmd -ServerInstance $env:COMPUTERNAME\SQL2012 &
  Get-ChildItem $dbloc\Tables&
&
&
&
&
  #-----------------------------------------------------------------------------------------------#&
  # Insert data into a table&
  #-----------------------------------------------------------------------------------------------#&
  Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012&
  &
  $dbcmd = @"&
    INSERT INTO dbo.SqlSaturday&
      (SqlSaturdayID, Organizer, Location, EventDate, Attendees)&
    VALUES&
      (111, 'John C Dvorak', 'San Francisco, CA', '2012/05/12', 150)&
"@&
  &
  # You can use the -Database parameter so you can be elsewhere in the provider&
  Invoke-Sqlcmd -Query $dbcmd `&
                -ServerInstance $env:COMPUTERNAME\SQL2012 `&
                -Database "PSTEST1" &
&
&
  # Reset location to database so we get proper context for the provider&
  Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases\PSTest1&
&
  $dbcmd = @"&
    INSERT INTO dbo.SqlSaturday&
      (SqlSaturdayID, Organizer, Location, EventDate, Attendees)&
    VALUES&
      (112, 'Adam Curry', 'Austin, Tx', '2012/05/12', 150)&
"@&
&
  # Can use the supress switch to prevent further warnings from appearing&
  Invoke-Sqlcmd -Query $dbcmd `&
                -ServerInstance $env:COMPUTERNAME\SQL2012 `&
                -SuppressProviderContextWarning &
&
&
&
&
##&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
  #-----------------------------------------------------------------------------------------------#&
  # Get data out of the table&
  #-----------------------------------------------------------------------------------------------#&
&
  # You might think you can set the current location to the table and see it's data&
  Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases\PSTest1\Tables\dbo.SqlSaturday&
  Get-ChildItem &
&
  # Nope. Instead query the data&
  $dbcmd = @"&
    SELECT SqlSaturdayID, Organizer, Location, EventDate, Attendees&
      FROM dbo.SqlSaturday&
     WHERE SqlSaturdayID = 112 &
"@&
  Clear-Host&
  Invoke-Sqlcmd -Query $dbcmd `&
                -ServerInstance $env:COMPUTERNAME\SQL2012 `&
                -SuppressProviderContextWarning `&
&
  # Let's put the output into a variable we can use&
  Clear-Host&
  $myOutput = Invoke-Sqlcmd -Query $dbcmd `&
                            -ServerInstance $env:COMPUTERNAME\SQL2012 `&
                            -SuppressProviderContextWarning `&
&
&
  # See the result&
  $myOutput                            # As the default table&
  $myOutput | Format-Table -AutoSize   # As a list&
  $myOutput.Organizer                  # Get one element of it&
&
  # System.Data.DataRow datatype&
  $myOutput.GetType()&
&
  # Get-Member will give you a full type name in addition to other info&
  $myOutput | Get-Member&
&
##&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
  #-----------------------------------------------------------------------------------------------#&
  # Dealing with sets of data&
  #-----------------------------------------------------------------------------------------------#&
  Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases\PSTest1\Tables\dbo.SqlSaturday&
&
  # Let's load in a bit more data&
  $dbcmd = @"&
    INSERT INTO dbo.SqlSaturday&
      (SqlSaturdayID, Organizer, Location, EventDate, Attendees)&
    VALUES&
      (141, 'Brian Knight', 'Orange City, FL', '2012/06/16', 141)&
    , (132, 'Mike Davis', 'Jacksonville, FL', '2012/06/09', 132)&
    , (150, 'Jorge Segarra', 'Baton Rouge, LA', '2012/08/04', 150)&
    , (151, 'Adam Jorgensen', 'Orlando, FL', '2012/09/29', 151)&
    , (144, 'Kathi Kellenberger', 'Nashville, TN', '2012/10/13', 144)&
"@&
&
  Invoke-Sqlcmd -Query $dbcmd `&
                -ServerInstance $env:COMPUTERNAME\SQL2012 `&
                -SuppressProviderContextWarning `&
&
  # Query the data to see our new rows&
  $dbcmd = @"&
    SELECT SqlSaturdayID, Organizer, Location, EventDate, Attendees&
      FROM dbo.SqlSaturday&
     ORDER BY EventDate&
"@&
  Clear-Host&
  $myOutput = Invoke-Sqlcmd -Query $dbcmd `&
                            -ServerInstance $env:COMPUTERNAME\SQL2012 `&
                            -SuppressProviderContextWarning `&
&
  $myOutput | Format-Table -AutoSize&
&
  # Getting to certain rows&
  $myOutput.Count   # How many rows we have&
  $myOutput[3].Location   # Remember arrays are 0 based!&
  &
  # Iterating over the collection of rows&
  foreach($row in $myOutput)&
  {&
    Write-Host $row.Organizer&
  }&
&
  # Note myOutput is now an array datatype&
  $myOutput.GetType()&
&
  # It's an array of System.Data.DataRow objects&
  $myOutput[0] | Get-Member&
&
&
&
&
##&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
  #-----------------------------------------------------------------------------------------------#&
  # Drop the database now that we're done&
  #-----------------------------------------------------------------------------------------------#&
&
  # All done let's drop the db&
  &
  # Move our current location so it doesn't interfere with the drop&
  Set-Location SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases&
  &
  # Create the drop command&
  $dbcmd = @"&
    USE master;&
    GO&
    ALTER DATABASE [PSTest1]&
    SET SINGLE_USER &
    WITH ROLLBACK IMMEDIATE;&
    GO&
   DROP DATABASE [PSTest1]&
"@&
&
  # Run the drop&
  Invoke-Sqlcmd -Query $dbcmd `&
                -ServerInstance $env:COMPUTERNAME\SQL2012 `&
                -SuppressProviderContextWarning `&
&
  Get-ChildItem SQLSERVER:\sql\$env:COMPUTERNAME\SQL2012\databases |&
    Select-Object -Property Name, Status, RecoveryModel, Owner |&
    Format-Table -Autosize&
&
  # At this point you get the idea. You can use T-SQL to do anything to the server or database&
&
&
&
##&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
###&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
&
# Mention Encode-SQLName&

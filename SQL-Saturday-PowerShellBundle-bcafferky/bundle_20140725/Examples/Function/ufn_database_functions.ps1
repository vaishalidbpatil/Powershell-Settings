   <#
      Useful Database Function...
      
      Author:  Don Jones with some enhancements by Bryan Cafferky
      
      From http://technet.microsoft.com/en-us/magazine/hh855069.aspx
      
      Points:
      
      - Verbose option
      - Switch parameter
      - named paramters on call
         
   
   #>
   
   # Function to get data from a SQL table...
    function Get-DatabaseData {
        [CmdletBinding()]
        param (
            [string]$connectionString,
            [string]$query,
            [string]$outpath,
            [switch]$writeToFile,
            [switch]$isSQLServer
          )
        if ($isSQLServer) {
            Write-Verbose 'in SQL Server mode'
            $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
        } else {
            Write-Verbose 'in OleDB mode'
            $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
        }
        $connection.ConnectionString = $connectionString
        $command = $connection.CreateCommand()
        $command.CommandText = $query
        if ($isSQLServer) {
            $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
        } else {
            $adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command
        }
        $dataset = New-Object -TypeName System.Data.DataSet
        $adapter.Fill($dataset)
        
        if ($writeToFile) 
        {
           $dataset.Tables[0] > $outpath
        }   
           else { $dataset.Tables[0] }
        
    }
    
    function Invoke-DatabaseQuery {
        [CmdletBinding()]
        param (
            [string]$connectionString,
            [string]$query,
            [switch]$isSQLServer
            )
        if ($isSQLServer) {
            Write-Verbose 'in SQL Server mode'
            $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
        } else {
            Write-Verbose 'in OleDB mode'
            $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
        }
        $connection.ConnectionString = $connectionString
        $command = $connection.CreateCommand()
        $command.CommandText = $query
        $connection.Open()
        $command.ExecuteNonQuery()
        $connection.close()
    }
    
function ufn_load_file_into_table {
        [CmdletBinding()]
        param (
            [string]$connectionString,
            [string]$mytable,
            [string]$path,
            [switch]$isSQLServer,
            [switch]$drop
            )
     
     if ($drop) 
     { 
       Try 
       {
         Invoke-DatabaseQuery -verbose -connectionString $connectionString -isSQLServer -query "drop table $mytable" 
         write-host "Dropped table..."
       }
       Catch 
       {
          Write-host "Table could not be dropped."
       }
     }    
             
               
    $create = "create table $mytable ( "
    $insert = "insert into $mytable values ( "
  
    $myfile = import-csv $path
 
 #   $colnames | get-member|  where-object {$_.MemberType -eq "NoteProperty"} 
    $colnames  = $myfile | get-Member |  where-object {$_.MemberType -eq "NoteProperty"} ; #| out-gridview; 
    $colvalues = $myfile | get-Member |  where-object {$_.MemberType -eq "Value"} ;
   
   # $fn ="firstname"
   # $myfile[0].$fn

   [string[]] $colname = ""
 
   $i = 0;
   $colnames | sort-object  -descending |  foreach-object { 
     $i++ ; 
     $cn = $_.Name   ;
     $colname += $cn
     $create = $create + $cn + " varchar(200) ,"
   }; 
 
 $create = $create.substring(0,$create.length - 2) + " )"
 
 write-verbose $create
 
 Invoke-DatabaseQuery -verbose -connectionString $connectionString -isSQLServer -query $create  
 
 
 foreach ( $line in $myfile )  
 { 
 
   $insline = ""
 
   foreach ( $item in $colname ) 
      { 
         $insline = $insline + "'" + $line.$item + "' ," 
      }
      
   $insline = $insline.substring(4,$insline.length - 5)
   $insline = $insline + " )"
    
   $inssql = $insert + $insline 
   
   write-verbose $inssql
       
   Invoke-DatabaseQuery -verbose -connectionString $connectionString -isSQLServer -query  $inssql 
     
 }

            
 }       
 
 ufn_load_file_into_table -verbose  'Server=localhost;Database=AdventureWorks;Trusted_Connection=True;' 'mytable8' 'C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\infile.csv' -isSQLServer -Drop
 
# Demo Stop


   
   # Example Calls: 
   
   #  Query table putting results into a text file...
  #  Get-DatabaseData -verbose -connectionString 'Server=localhost;Database=AdventureWorks;Trusted_Connection=True;' -query "SELECT FirstName + ' ' + LastName FROM [Person].[Person]" -writeToFile -outpath 'C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\outdb1.txt' -isSQLServer
  
  # Create a new table...
  # Invoke-DatabaseQuery -verbose -connectionString 'Server=localhost;Database=AdventureWorks;Trusted_Connection=True;' -isSQLServer -query "Create table dbo.mytable321 (id integer identity(1,1) not null primary key clustered, firstname varchar(100), lastname varchar(100) )"  
 
  # "Hello World".ToUpper()
  
 
  
   
  
  <#
  
  $tablename = Read-host "Enter the table name" 
  
  # Create the table...
  Invoke-DatabaseQuery -verbose -connectionString 'Server=localhost;Database=AdventureWorks;Trusted_Connection=True;' -isSQLServer -query "Create table $tablename (id integer identity(1,1) not null primary key clustered, firstname varchar(100), lastname varchar(100) )"  
   
  
  [string] $input = "start"
  $input.ToUpper()
  while ( $input.ToUpper() -ne "END" ) { 
  
    $firstname = read-host "Enter First Name: "
  
    $lastname = read-host "Enter Last Name: "
  
    $input = read-host "Enter 'End' to stop: "
  
    $sql = "INSERT INTO $tablename (firstname, lastname) VALUES('$firstname', '$lastname' )"
    $sql
  
    Invoke-DatabaseQuery -verbose -connectionString 'Server=localhost;Database=AdventureWorks;Trusted_Connection=True;' -isSQLServer -query $sql
    
  }
 #>
    
 #   Invoke-DatabaseQuery -verbose -connectionString 'Server=localhost;Database=AdventureWorks;Trusted_Connection=True;' -isSQLServer -query "INSERT INTO dbo.mytable (firstname, lastname) VALUES($firstname, $lastname )"
 
 # Get-DatabaseData -verbose -connectionString 'Server=localhost\SQLEXPRESS;Database=Inventory;Trusted_Connection=True;' -isSQLServer-query "SELECT * FROM Computers"
   
   
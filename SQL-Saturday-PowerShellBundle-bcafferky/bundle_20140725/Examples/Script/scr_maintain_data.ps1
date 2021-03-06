
<#  Author:  Bryan Cafferky, BPC Global Solutions, LLC     2014-07-13

Purpose:  Demo how to do data maintenance via PowerShell.

#>


function ufn_check_for_module_and_load (
    [string]$modulename
    )
{
if(-not(Get-Module -name $modulename)) {
          Import-Module $modulename 
          }
} 

ufn_check_for_module_and_load "sqlps" #  We need to make sure the SQLPS module is loaded. 


While (1 -eq 1 )
{

$action = read-host "Please enter an action (a = add, d = delete, c = change, l = list)..."

If ($action -eq "d")
   {
   $key = read-host "Please enter the key of the row you want to delete..."
   $data = Invoke-Sqlcmd -ServerInstance "localhost" -Database "Development" -Query "select * from dbo.student where id = $key"
   "Row to be deleted..."
   $data
   $answer = read-host "Delete record (y/n)?" 
   if ($answer.toupper() -eq "Y" )
       {
       Invoke-Sqlcmd -ServerInstance "localhost" -Database "Development" -Query "delete from dbo.student where id = $key"
       "Record deleted."
       }
   else { "Deletion aborted..." }    
   }
ElseIf ($action -eq "c")
   {
   $key = read-host "Please enter the key of the row you want to change..."
   $data = Invoke-Sqlcmd -ServerInstance "localhost" -Database "Development" -Query "select * from dbo.student where id = $key"
   "The record you are about to change is displayed below..."
   $data
   $fn = read-host  "Enter new First Name" 
   $ln = read-host  "Enter new Last Name" 
   $age = read-host "Enter new Age" 
   $sqlupdate = "update dbo.student set fname = '$fn', lname = '$ln', age = $age where id = $key"
   Invoke-Sqlcmd -ServerInstance "localhost" -Database "Development" -Query $sqlupdate
   write-host "Updated Record..."
   Invoke-Sqlcmd -ServerInstance "localhost" -Database "Development" -Query "select * from dbo.student where id = $key" 
   }   
ELSEIF ($action -eq "a")
   {
   $fn = read-host  "Enter new First Name" 
   $ln = read-host  "Enter new Last Name" 
   $age = read-host "Enter new Age" 
   $sqlinsert = "insert into dbo.student (fname, lname, age) Values ('$fn', '$ln', $age)"
   Invoke-Sqlcmd -ServerInstance "localhost" -Database "Development" -Query $sqlinsert
   write-host "Inserted Record..."
   Invoke-Sqlcmd -ServerInstance "localhost" -Database "Development" -Query "select * from dbo.student where id = IDENT_CURRENT( 'dbo.student' )"  
   }
ELSEIF ($action -eq "l")
   {
   Invoke-Sqlcmd -ServerInstance "localhost" -Database "Development" -Query "select * from dbo.student"
   }
ELSE
   { write-host "bad action" }
      

}


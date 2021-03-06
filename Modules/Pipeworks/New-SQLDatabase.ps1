function New-SQLDatabase
{
    <#
    .Synopsis
        Creates a new SQL database
    .Description
        Creates a database in SQL server, SQL azure, SQLCompact, or Sqlite
    #>
    [CmdletBinding(DefaultParameterSetName='SqlServer')]
    param(
    [Parameter(Mandatory=$true,ParameterSetName='SqlServer')]
    [string]
    $DatabaseName,

    # The name of the SQL server.  By default, the local machine
    [Parameter(ParameterSetName='SqlServer')]
    [Alias('CN')]
    [string]
    $ComputerName = $env:COMPUTERNAME,

    # If set, will create a SQLite database
    [Parameter(Mandatory=$true,ParameterSetName='Sqlite')]
    [Alias('UseSqlLite')]
    [Switch]
    $UseSqlite,

    # The path to SQLite. If not set, will import SQLite from program files
    [Parameter(ParameterSetName='Sqlite')]    
    [string]
    $SqlitePath,
    
    # If set, will use SQL compact
    [Parameter(Mandatory=$true,ParameterSetName='SqlCompact')]    
    [Switch]
    $UseSqlCompact,
    
    # The path the SQL compact.  If not provided, SQL compact will be loaded from the GAC.
    [Parameter(ParameterSetName='SqlCompact')]    
    [string]
    $SqlCompactPath,
            
    # The path to the database file.
    [Parameter(Mandatory=$true,ParameterSetName='SqlCompact')]
    [Parameter(Mandatory=$true,ParameterSetName='Sqlite')]
    [string]
    $DatabasePath,

    # A connection string or a setting containing a connection string.    
    [Alias('ConnectionString', 'ConnectionSetting')]
    [string]$ConnectionStringOrSetting
       
    )

    process {
        if ($PSBoundParameters.ConnectionStringOrSetting) {
            if ($ConnectionStringOrSetting -notlike "*;*") {
                $ConnectionString = Get-SecureSetting -Name $ConnectionStringOrSetting -ValueOnly
            } else {
                $ConnectionString =  $ConnectionStringOrSetting
            }
            $script:CachedConnectionString = $ConnectionString
        } elseif ($script:CachedConnectionString){
            $ConnectionString = $script:CachedConnectionString
        } elseif ($ComputerName) {
            $connectionString = "Data Source=$ComputerName;Initial Catalog=Master;Integrated Security=SSPI;"
        } else {
            $ConnectionString = ""
        }


        if ($UseSQLCompact) {
            if (-not ('Data.SqlServerCE.SqlCeConnection' -as [type])) {
                if ($SqlCompactPath) {
                    $resolvedCompactPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($SqlCompactPath)
                    $asm = [reflection.assembly]::LoadFrom($resolvedCompactPath)
                } else {
                    $asm = [reflection.assembly]::LoadWithPartialName("System.Data.SqlServerCe")
                }
            }
            

            $fullCreatePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DatabasePath)
            $sqlEngine = New-Object Data.SqlServerCE.SqlCeEngine "Data Source=$fullCreatePath"
            $sqlEngine.CreateDatabase()
            
        } elseif ($UseSqlite) {
            if (-not ('Data.Sqlite.SqliteConnection' -as [type])) {
                if ($sqlitePath) {
                    $resolvedLitePath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($sqlitePath)
                    $asm = [reflection.assembly]::LoadFrom($resolvedLitePath)
                } else {
                    $asm = [Reflection.Assembly]::LoadFrom("$env:ProgramFiles\System.Data.SQLite\2010\bin\System.Data.SQLite.dll")
                }
            }
                
            $fullCreatePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DatabasePath)
            [Data.Sqlite.SQliteConnection]::CreateFile($fullCreatePath)
        } else {
            $sqlConnection = New-Object Data.SqlClient.SqlConnection "$connectionString"
            $sqlConnection.Open()

            $cmd = $sqlConnection.CreateCommand()
            
            $cmd.CommandText = "CREATE DATABASE $DatabaseName"
            $null = $cmd.ExecuteNonQuery()
            $sqlConnection.Close()
            $sqlConnection.Dispose()
        }
    }
} 
 

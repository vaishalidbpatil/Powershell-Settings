# tests.ps1
#
# unit tests for MongoDB PowerShell Provider

param( $connectionString )

Import-Module psake;

# verify parameters
Write-Verbose "testing connectionString validity";
Assert ($connectionString) "A connectionString parameter must be supplied";

# verify the module import 
Write-Verbose "testing load of Mongo provider";
Import-Module Mongo;
Assert( Get-Module Mongo ) "Cannot load Mongo module";

#verify exported functions

#verify private functions


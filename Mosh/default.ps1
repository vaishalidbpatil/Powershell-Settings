# Copyright (c) 2011 Code Owls LLC
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy 
#	of this software and associated documentation files (the "Software"), 
#	to deal in the Software without restriction, including without limitation 
#	the rights to use, copy, modify, merge, publish, distribute, sublicense, 
#	and/or sell copies of the Software, and to permit persons to whom the 
# 	Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in 
#	all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
#	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
#	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
#	DEALINGS IN THE SOFTWARE. 
#
#
# for information regarding this project, to request features or 
#	report issues, please see: http://mosh.codeplex.com
#
#
# psake build script for the Membership PowerShell Provider project
#
# valid configurations:
#  Debug
#  Release
#
# notes:
#
# the Tests task relies on the value of the connectionString property;
#	to run Tests locally, you will need to set this property to a connection
#	string that is valid for your local environment.
#	
#	e.g.:
#	invoke-psake Tests -properties @{ connectionString='mongodb://foofooServer' };
#

properties {
	$config = 'Debug'; 	
	$keyContainer = '';
	$moduleInstallDirectory = $env:psmodulepath -split ';' | where{ $_.startsWith( (resolve-path '~') ) } | select -first 1;
	$moduleSrcDirectory = './src/module/Mongo';
	$csproj = './src/MongoProvider/CodeOwls.MongoProvider.csproj';
	$connectionString = 'mongodb://192.168.56.102';
};

$private = "this is a private task not meant for external use";

function get-packageDirectory
{
	return "./bin/$config/Mongo";
}

function get-outputDirectory
{
	return 	$outputDirectory = "./src/MongoProvider/bin/$config";
}

task default -depends All;

task All -depends Install;

task __VerifyConfiguration -description $private {
	Assert ( @('Debug', 'Release') -contains $config ) "Unknown configuration, $config; expecting 'Debug' or 'Release'";
	Assert ( Test-Path $csproj ) "Cannot find C# project, $csproj";
	Assert ( Test-Path $moduleSrcDirectory ) "Cannot find module source directory, $moduleSrcDirectory";
	
	Write-Verbose ("packageDirectory: " + ( get-packageDirectory ));
	Write-Verbose ("outputDirectory: " + ( get-outputDirectory ));
}

task __CreatePackageDirectory -description $private {
	$packageDirectory = get-packageDirectory;
	
	if( !(Test-Path $packageDirectory ) )
	{
		Write-Verbose "creating package directory at $packageDirectory ...";
		mkdir $packageDirectory;
	}
}

task Build -depends __VerifyConfiguration {
	exec{ msbuild $csproj /p:Configuration=$config /p:KeyContainerName=$keyContainer /t:Build }
}

task Clean -depends __VerifyConfiguration {
	exec{ msbuild $csproj /p:Configuration=$config /t:Clean }
}

task Rebuild -depends Clean,Build;

task Package -depends Build,__CreatePackageDirectory -description "assembles the Mongo Provider PowerShell module in the source hive"  {
	$packageDirectory = get-packageDirectory;
	$outputDirectory = get-outputDirectory;
	
	Write-Verbose "packaging from $outputDirectory to $packageDirectory ...";
	dir $moduleSrcDirectory  | Copy-Item -recurse -Destination $packageDirectory -force;
	dir $outputDirectory | Copy-Item -recurse -Destination $packageDirectory -force;
}

task Uninstall -depends __VerifyConfiguration -description "removes any existing Mongo Provider PowerShell module from your local environment" {
	$path = "$moduleInstallDirectory/Mongo";
	
	if( Test-Path $path )
	{
		Write-Verbose "removing installed module ...";
		Remove-Item $path -Recurse -Force;
	}
}

task Install -depends Uninstall,Package -description "installs the Mongo Provider PowerShell module to your local environment" {
	$packageDirectory = get-packageDirectory;
	
	Write-Verbose "installing module to $moduleInstallDirectory ...";
	Copy-Item $packageDirectory -Destination $moduleInstallDirectory -recurse;
}

task Test -depends Install -description "executes functional tests against the Mongo Provider PowerShell module" {
	Write-Verbose "running tests ...";
	
	# we run tests in a nested powershell session so the module will be unloaded from memory
	# 	after the tests are complete.
	#	this will allow us to rerun the build from the same console.
	powershell -command "& ./tests/tests.ps1 -connectionString '$connectionString'"
}
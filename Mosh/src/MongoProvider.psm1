# this is the StudioShell solution module for the MongoProvider solution
import-module psake;

# wire up PSake for builds
function invoke-build
{
	pushd $psakeDir;
	invoke-psake -buildFile $psakeFile -task Build
	popd;
}

function invoke-clean
{
	pushd $psakeDir;
	invoke-psake -buildFile $psakeFile -task Clean
	popd;
}

function invoke-rebuild
{
	pushd $psakeDir;
	invoke-psake -buildFile $psakeFile -task Rebuild
	popd;
}

function invoke-package
{
	pushd $psakeDir;
	invoke-psake -buildFile $psakeFile -task Package
	popd;
}

function invoke-test
{
	pushd $psakeDir;
	invoke-psake -buildFile $psakeFile -task Test
	popd;
}

function invoke-install
{
	pushd $psakeDir;
	invoke-psake -buildFile $psakeFile -task Install
	popd;
}

function invoke-uninstall
{
	pushd $psakeDir;
	invoke-psake -buildFile $psakeFile -task Uninstall
	popd;
}

function invoke-msbuild()
{
	[CmdletBinding()]
	param(
		[Parameter(ValueFromRemainingArguments=$true)]
		[string[]] 
		$args
	)

	$args = $args -join ' '
	write-host "INVOKING MSBUILD with [$args]";	
	remove-item alias:/msbuild;
	exec ( [scriptblock]::create( "msbuild $args" ) );
	set-alias msbuild invoke-msbuild -scope global -option allscope;
}

function mount-psakeDir
{
	pushd $psakeDir;
}

set-alias msbuild invoke-msbuild -scope Global -option AllScope;

$addedCommands = @();
$psakeFile = ( get-item "projects:/solution Items/default.ps1" ).FileName;
$psakeDir = split-path $psakeFile;

#undo everything when the module is unloaded
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
	remove-module psake;
	$addedCommands | remove-item;
}
function Get-Hash
{
    <#
    .Synopsis
        Gets a hash code for an object
    .Description
        Gets a hash code for an object
    .Example
        1..10 | Get-Hash
    .Example
        dir | Get-Hash
    #>
    param(
    # The input object
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
    [PSObject]
    $InputObject,

    # The algorithm to use.  By default, MD5
    [Parameter(Position=1)]
    [ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512', 'HMAC')]
    [string]
    $Algorithm = 'MD5',    

    # If set, will output an object containing the input, hash, and algorithm
    [Switch]
    $OutputObject
    )

    process {
        $inBytes= if ($InputObject -is [Hashtable]) {            
            [Text.Encoding]::Unicode.GetBytes((Write-PowerShellHashtable -InputObject $InputObject).Trim().ToLower())
        } elseif ($inputObject -As [byte[]]) {
            $inputObject -As [byte[]]
        } elseif ($inputObject -is [string]) {
            [Text.Encoding]::Unicode.GetBytes(("$InputObject".Trim().ToLower()))
        } else {
            $hashtable = @{}
            foreach ($prop in $InputObject.psobject.properties) {
                $hashtable[$prop.Name] = $prop.value
            }
            [Text.Encoding]::Unicode.GetBytes((Write-PowerShellHashtable -InputObject $hashtable).Trim().ToLower())
        }


        $hasher= ("Security.Cryptography.$Algorithm" -as [Type])::Create()
        $bytes = $hasher.ComputeHash($inBytes)
            

        

        if ($OutputObject) {
            $hash = @(foreach ($b in $bytes)  {"{0:x}" -f $b }) -join '' 
            $psOBj = New-Object PSObject 
            Add-Member NoteProperty Algorithmn $Algorithm -InputObject $psObj -force 
            Add-Member NoteProperty Input $inputObject -InputObject $psObj -force 
            Add-Member NoteProperty Hash $hash -InputObject $psObj -force 
            $psOBj 
        } elseif ($asbyte) {
            $bytes
        } else { 
            @(foreach ($b in $bytes)  {"{0:x}" -f $b }) -join '' 
        } 
        
    }
} 

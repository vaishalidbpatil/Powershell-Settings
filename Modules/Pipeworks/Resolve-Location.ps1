function Resolve-Location
{
    <#
    .Synopsis
        Resolves a location to it's place on Earth
    .Description
        Looks up physical addresess (in the US), ip addresses, or hostnames.
        
        Returns results as a [http://schema.org/Place](http://schema.org/Place)        

    .Example
        # Resolve Location by GeoIP
        Resolve-Location -Address "69.89.88.122"
    .Example
        # Resolve physical locations within the US
        Resolve-Location -Address "1600 Pennsylvania Ave, Washington, DC"
    #>
    param(
    [Parameter(Mandatory=$true)]
    [string]$Address
    ) 

    begin {
        
        if (-not $script:resolvedLocations) {
            $script:resolvedLocations= @{}
        }
    }

    process {
        if (-not $script:resolvedLocations[$address]) {
            $script:resolvedLocations[$address] = 

                if (($address -notlike "* *") -and 
                    ($address -as [IPAddress] -or $Address -like "*.*")) {
                    # IpAddress or hostname    
                    $lookup = Get-Web -Url "http://freegeoip.net/json/$Address" -AsJson
                    if (-not $lookup) { return } 
                    $lookup.pstypenames.clear()
                    $lookup.pstypenames.add('http://schema.org/Place')
                    $lookup | 
                        Add-Member AliasProperty Country Country_Name -Force -PassThru |
                        Add-Member AliasProperty Locality City -Force -PassThru |
                        Add-Member AliasProperty PostalCode ZipCode -Force -PassThru
                } else {        
                    $safeAddress = [Web.HttpUtility]::UrlEncode($address)
        
        
                    # Pick out the pieces of the addres
                    $streetAddress, $locality, $region = $Address -split ","
        
                    $chunks = @($region -split " " -ne "")
                    if ($chunks.Count -gt 1 ) {
                        $postalCode = $chunks[-1]
                        $region = $chunks[0..($chunks.Count -2)] -join " " 
                    } 
            
                    $tr = Get-Web -Url "http://geocoder.us/demo.cgi?address=$safeAddress"  -tag tr
                    $rows = 
                        $tr | 
                
                        Select-Object -First 2 -Skip 1 | 
                        ForEach-Object { $_.Xml.Td}  
                
                    if (-not $rows) {
                        Write-Error "Address could not be resolved"
                        return
                    }

                    $lat = $rows[1].innerText -split "[$([Environment]::NewLine)]" | 
                        Select-Object -First 1 
                    $long = $rows[3].innerText -split "[$([Environment]::NewLine)]" | 
                        Select-Object -First 1 
                
                    $out = New-Object PSObject |
                        Add-Member NoteProperty StreetAddress "$streetAddress".Trim() -Force -PassThru |
                        Add-Member NoteProperty Locality "$locality".Trim() -Force -PassThru |
                        Add-Member NoteProperty Region "$Region".Trim() -Force -PassThru |
                        Add-Member NoteProperty PostalCode "$postalCode".Trim() -Force -PassThru |
                        Add-Member NoteProperty Latitude ($lat.Trim().TrimEnd("°").Trim() -as [Double]) -Force -PassThru |
                        Add-Member NoteProperty Longitude ($long.Trim().TrimEnd("°").Trim() -as [Double]) -Force -PassThru             
            
                    $out.pstypenames.clear()
                    $out.pstypenames.add('http://schema.org/Place')
                    $out          
                }
        }


        $script:resolvedLocations[$address]
        
    }
}
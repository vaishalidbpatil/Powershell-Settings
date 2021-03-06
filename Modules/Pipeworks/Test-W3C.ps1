function Test-W3C
{
    <#
    .Synopsis
        Tests compliance with the W3C standards
    .Description
        Validates a page's HTML5 compliance with the W3CValidator
    #>
    param(
    # The URL you'd like to validate
    [Parameter(Mandatory=$true,Position=0,ParameterSetName='Url')]
    [Uri]
    $Url
    ) 
    
    process {
        $sUrl  = [Web.HttpUtility]::UrlEncode("$url")
        $p = get-web -Url "http://validator.w3.org/check?uri=$sUrl&charset=%28detect+automatically%29&doctype=Inline&group=0" 
        if (-not $p) {
            return
        }
        $ol = Get-Web -html $p -Tag 'ol' | Where-Object {$_.Tag -like '*error_loop*'}

        if (-not $ol) {
            return
        }

        $li = $ol.Xml.SelectNodes("li")

        foreach ($l in $li) {
            $lineAndColumn = $l.em -replace "[$([Environment]::NewLine)]", '' -replace '\s{2,}', ''
            $err = $l.span[1].'#text'
            $errType = $l.span[0].img.alt
            $line, $column = $lineAndColumn -split ',' 
            $line = ($line -split ' ')[1] -as [uint32]
    
            $column = ($column -split ' ')[1] -as [uint32]
            New-Object PSObject -Property @{
                Line = $line
                Column = $column
                Error = $err
                ErrorType = $errType
            }
        }

    
    }   

}

 

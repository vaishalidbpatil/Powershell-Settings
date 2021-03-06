function Select-Wmi
{
    <#
    .Synopsis
        Queries WMI as a datastore
    .Description
        Select-WMI pulls data from the WMI repository and fixes the typename, which allows for the full use
    #>
    param(
    # The WQL used to query the object.
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true,ParameterSetName='Wql')]    
    [string]
    $WQl,

    # The namespace that is being queried
    [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
    [string]
    $Namespace,

    # A list of computers to connect to
    [string[]]
    $ComputerName,
    
    # The namespace that is being queried
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='Class')]
    [string]
    $ClassName,
    
    # The query filter
    [Parameter(Position=3,ValueFromPipelineByPropertyName=$true,ParameterSetName='Class')]
    [string]
    $Filter,
    
    # If provided, the object will be sorted 
    [PSObject[]]            
    $Sort,

    # If set, the sort order will be descending instead of ascending
    [Switch]
    $Descending
    )


    begin {
        $getRealClassName = {
        
            $tn = $Typename.Replace("_space_"," ").Replace("_dot_",".").Replace("_colon_",":").Replace("_slash_", "/").Replace("_pound_","#")


            if ($tn.StartsWith("Number")) {
                $tn.Substring("Number".Length)
            } else {
                $tn
            }
        }
        $getSafeClassName = {
        
            $cn = $ClassName.Replace(" ", "_space_").Replace("." ,"_dot_").Replace(":", "_colon_").Replace("/", "_slash_").Replace("#", "_pound_")            


            if ($(try { [uint32]::Parse($cn[0]) } catch {})) {
                "Number" + $cn
            } else {
                $cn
            }

        }
    }
    process {
        & {
            param($param) 
            
            if ($PSCmdlet.ParameterSetName -eq 'WQL') {
                $params = @{} + $param
                $null = $params.Remove("WQL")
                $null = $params.Remove("Sort")
                $null = $params.Remove("Descending")
                Get-WmiObject -Query $wql @params
            } elseif ($PSCmdlet.ParameterSetName -eq 'Class') {
                $params = @{} + $param
                $null = $params.Remove("ClassName")
                $null = $params.Remove("Sort")
                $null = $params.Remove("Descending")
                Get-WmiObject -Class (. $getSafeClassName) @params
            }
        } $PSBoundParameters |        
            ForEach-Object {
                $o = $_
                $typename = ($_ -as [psobject]).pstypenames[0]
                $typeName = $typename.Substring($typename.IndexOf("#") + 1)
                $typeName = $typename.Substring($typename.LastIndexOf("\") + 1)
                $typeName = . $getRealClassName



                $pso = ($o -as [psObject])
                $pso.pstypenames.clear()
                $pso.pstypenames.add($typename)
                $pso
            } |
            ForEach-Object -Begin {
                 if ($sort) {
                    $objectList = New-Object Collections.arraylist
                 }
            } -Process {
                if ($sort) {
                    $null = $ObjectList.Add($_)
                } else {
                    $_
                }
            } -End {
                if ($sort) {
                    $objectList | Sort-Object $sort -Descending:$Descending
                }
            }
    }
} 

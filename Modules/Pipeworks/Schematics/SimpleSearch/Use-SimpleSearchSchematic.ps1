function Use-SimpleSearchSchematic
{
    <#
    .Synopsis
        Builds a web application according to a schematic
    .Description
        Use-Schematic builds a web application according to a schematic.
        
        Web applications should not be incredibly unique: they should be built according to simple schematics.        
    .Notes
    
        When ConvertTo-ModuleService is run with -UseSchematic, if a directory is found beneath either Pipeworks 
        or the published module's Schematics directory with the name Use-Schematic.ps1 and containing a function 
        Use-Schematic, then that function will be called in order to generate any pages found in the schematic.
        
        The schematic function should accept a hashtable of parameters, which will come from the appropriately named 
        section of the pipeworks manifest
        (for instance, if -UseSchematic Blog was passed, the Blog section of the Pipeworks manifest would be used for the parameters).
        
        It should return a hashtable containing the content of the pages.  Content can either be static HTML or .PSPAGE                
    #>
    [OutputType([Hashtable])]
    param(
    # Any parameters for the schematic
    [Parameter(Mandatory=$true)][Hashtable]$Parameter,
    
    # The pipeworks manifest, which is used to validate common parameters
    [Parameter(Mandatory=$true)][Hashtable]$Manifest,
    
    # The directory the schemtic is being deployed to
    [Parameter(Mandatory=$true)][string]$DeploymentDirectory,
    
    # The directory the schematic is being deployed from
    [Parameter(Mandatory=$true)][string]$InputDirectory     
    )
    
    process {
    
       
        
        if (-not $Manifest.Table.Name) {
            Write-Error "No table found in manifest"
            return
        }
        
        if (-not $Manifest.Table.StorageAccountSetting) {
            Write-Error "No storage account name setting found in manifest"
            return
        }
        
        if (-not $manifest.Table.StorageKeySetting) {
            Write-Error "No storage account key setting found in manifest"
            return
        }
        
                                        
        
        $simpleSearchPage = {

$titleBar = @"
<table>
<tr>
<td style='width:20%'>
$(Write-Link -Url '' -Caption "<span style='font-size:x-large'>$($module.Name)</span>")
</td>
<td style='width:50%;text-align:right'>
$("<span style='font-size:large;text-align:right'>$($module.Description)</span>")
</td>
<td style='width:10%;text-align:right'
</td>
</tr>
</table>
"@ | New-Region -layerId Titlebar -CssClass clearfix, theme-group, corner-all -Style @{
    
    "margin-top" = "1%"  
    "margin-left" = "12%"
    "margin-right" = "12%"    
}   
   
$results = 
    if ($Request['Term']) {
    @"
<div id='OutputContainer'>    
    Searching $($Module.Name) <progress max='100'> </progress>
</div>
<script>
    query = 'Module.ashx?Search=' + '$($Request['Term'])'
        
"@ + @'
    $(function() {
        $.ajax({
            url: query,
            success: function(data){     
                $('#OutputContainer').html(data);
            } 
        })
    })
</script>
'@
    } else {
        ""
    }

$outputRegion = 
    New-Region -layerId outputContent -Style @{
        "margin-left" = "2%"
        "margin-right" = "2%"
    } -Content $results


$browserSpecificStyle =
    if ($Request.UserAgent -clike "*IE*") {
        @{'height'='75%'}
    } else {
        @{'min-height'='75%'}
    }  
   
$mainRegion = @"
<div style='text-align:center;'>

<form>
    <br/>
    <br/>
    <p style='text-align:center'>
        <input name='term' value='$([Web.HttpUtility]::HtmlAttributeEncode($request['Term']))'type='text' style='width:80%' placeholder=''>
    </p>
    <p style='text-align:right'>
        <input value='Search $($module.Name)' style='width:20%;margin-right:10%'  type='submit'> 
    </p>
    <script>
        `$(function() {
            `$("input:submit").button();
        })
    </script>               
</form>
$outputRegion
</div>
"@ | 
    New-Region -CssClass theme-group, corner-all, ui-widget-content, clearfix -Style (@{
    "margin-top" = "0%"  
    "margin-left" = "12%"
    "margin-right" = "12%"    
} + $browserSpecificStyle)


$adSenseId = $pipeworksManifest.AdSenseId
$adslot = $pipeworksManifest.AdSlot

$adChunk = @"
<script type='text/javascript'>
<!--
google_ad_client = 'ca-pub-$adSenseId';
/* AdSense Banner */
google_ad_slot = '$adslot';
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type='text/javascript'
src='http://pagead2.googlesyndication.com/pagead/show_ads.js'>
</script>
"@        

$pipeworksBranding = 
    if ($pipeworksManifest.HidePipeworksBranding) {
""    
    } else {
@"
<div style='float:bottom'>
    <span style='font-size:xx-small'>Built with <a href='http://PowerShellPipeworks.com'>PowerShell Pipeworks</a>
</div>
"@    
    }
    
$advert = 
    New-Region -Style @{
        "margin-top" = "1%"  
        "margin-left" = "12%"
        "margin-right" = "12%"
        "text-align" = "center" 
    } -Content @"
$adChunk
<br/>
<br/>
$pipeworksBranding
"@

$titleBar, $mainRegion, $advert |
New-WebPage -Title $module.Name -UseJQueryUI

}

        
        
               
        @{
            "default.pspage" = "<| $simpleSearchPage  |>"                         
            "Search.pspage" = "<| $simpleSearchPage  |>"
            
        }                                   
    }        
} 
 

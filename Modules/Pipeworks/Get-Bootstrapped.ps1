function Get-Bootstrapped
{
    <#
    #>
    param(
    # The foreground color of the theme
    #|Color
    #|Default 0248b2           
    [string]$ForegroundColor,

    # The background color of the theme
    #|Color
    #|Default fafafa
    [string]$BackgroundColor,

    # The color used for links in the theme
    #|Color
    #|Default 012456
    [string]$LinkColor,
    
    # The fonts to use in the theme
    #|Default Segoe UI, Arial, sans-serif
    [string]$FontFamily,

    # The font size to use in the theme
    #|Default 15px
    [string]$FontSize,

    # The line height used in the theme.
    #|Default 21px
    [string]$LineHeight,

    # If set, will output a property bag containing the settings and the theme. If this is omitted, the theme will be directly returned.
    [Switch]$OutputObject
    )

    process {
        $fgColor= if ($foreGroundColor) { 
            "#" + $foreGroundColor.Trim('#')
        } elseif ($pipeworksManifest.Style.Body.color) {
            $pipeworksManifest.Style.Body.color
        } else {
            "#0248b2"
        }


        $lColor=  if ($linkColor) {
            '#' + $LinkColor.Trim('#')
        } elseif ($pipeworksManifest.Style.a.color) {
            $pipeworksManifest.Style.a.color
        } else {
            "#012456"
        } 

        $bgColor= if ($backgroundColor) {
            '#' + $backgroundColor.Trim('#')
        } elseif ($pipeworksManifest.Style.body.'background-color') {
            $pipeworksManifest.Style.body.'background-color'
        } else {
            "#fafafa"
        }
            
            
        $fontFam= if ($fontFamily) {
            $FontFamily    
        } elseif ($pipeworksManifest.Style.body.'font-family') {
            $pipeworksManifest.Style.body.'font-family'
        } else {
            "'Segoe UI', Helvetica, Arial, sans-serif"
        } 

        $fs = if ($fontsize) {
            $fontSize
        } elseif ($pipeworksManifest.Style.body.'font-size') {
            $pipeworksManifest.Style.body.'font-size'
        } else {
            '15px'
        }
            
        $lh = if ($lineHeight) {
            $LineHeight
        } elseif ($pipeworksManifest.Style.body.'line-height') {
            $pipeworksManifest.Style.body.'line-height'
        } else {
            '21px'
        } 

        # Download a customized bootstrap, containing their core color scheme.            

        $r = $null

        $r =
            Get-web -Url "http://bootstrap.herokuapp.com/" -Method POST -Parameter @{
                js = '["bootstrap-transition.js","bootstrap-modal.js","bootstrap-dropdown.js","bootstrap-scrollspy.js","bootstrap-tab.js","bootstrap-tooltip.js","bootstrap-popover.js","bootstrap-affix.js","bootstrap-alert.js","bootstrap-button.js","bootstrap-collapse.js","bootstrap-carousel.js","bootstrap-typeahead.js"]'
                css= '["reset.less","scaffolding.less","grid.less","layouts.less","type.less","code.less","labels-badges.less","tables.less","forms.less","buttons.less","sprites.less","button-groups.less","navs.less","navbar.less","breadcrumbs.less","pagination.less","pager.less","thumbnails.less","alerts.less","progress-bars.less","hero-unit.less","media.less","tooltip.less","popovers.less","modals.less","dropdowns.less","accordion.less","carousel.less","wells.less","close.less","utilities.less","component-animations.less","responsive-utilities.less","responsive-767px-max.less","responsive-768px-979px.less","responsive-1200px-min.less","responsive-navbar.less"]'
                vars="{
`"@bodyBackground`":`"$bgColor`",
`"@inputBackground`":`"$fgColor`",
`"@tableBackground`":`"$bgColor`",
`"@heroUnitBackground`":`"$bgColor`",
`"@heroUnitHeadingColor`":`"$fgColor`",
`"@heroLeadColor`":`"$fgColor`",
`"@infoBackground`":`"$bgColor`",
`"@infoText`":`"$fgColor`",
`"@placeHolderText`":`"$fgColor`",
`"@headingsColor`":`"$fgColor`",
`"@tableBackgroundAccount`":`"$bgColor`",
`"@tableBackgroundHover`":`"$fgColor`",
`"@navbarBackground`":`"$bgColor`",
`"@navbarBackgroundHighlight`":`"$fgColor`",
`"@navbarSearchBackground`":`"$bgColor`",
`"@navbarLinkBackgroundActive`":`"$fgColor`",
`"@navbarSearchBackgroundFocus`":`"$fgColor`",
`"@navbarText`":`"$fgColor`",
`"@navbarBrandColor`":`"$fgColor`",
`"@navbarLinkColor`":`"$lColor`",
`"@navbarLinkColorHover`":`"$fgColor`",
`"@navbarLinkColorActive`":`"$fgColor`",
`"@dropDownBackground`":`"$bgColor`",
`"@textColor`":`"$fgColor`",
`"@dropdownBackground`":`"$bgColor`",
`"@dropdownLinkColor`":`"$lColor`",
`"@dropdownLinkColorHover`":`"$fgColor`",
`"@dropdownLinkBackgroundHover`":`"$lColor`",
`"@btnPrimaryBackground`":`"$bgColor`",
`"@btnPrimaryBackgroundHighlight`":`"$bgColor`",
`"@formActionsBackground`":`"$bgColor`",
`"@linkColor`":`"$lColor`",
`"@sansFontFamily`":`"$fontFam`",
`"@monoFontFamily`":`"Menlo, Monaco, 'Consolas'`",
`"@baseFontSize`":`"$fSize`",
`"@baseLineHeight`":`"$lh`"}"
                img='["glyphicons-halflings.png","glyphicons-halflings-white.png"]'
} -AsByte -UseWebRequest


        if ($OutputObject) {
            
            $outObject = New-Object PSObject 
            $outObject  | Add-member NoteProperty ForegroundColor $fgColor -Force
            $outObject  | Add-member NoteProperty BackgroundColor $bgColor -Force
            $outObject  | Add-member NoteProperty LinkColor $lColor -Force
            $outObject  | Add-member NoteProperty FontSize $fs -Force
            $outObject  | Add-member NoteProperty FontFamily $fontFam -Force
            $outObject  | Add-member NoteProperty LineHeight $lh -Force

            $outObject  | Add-Member NoteProperty ThemeData $r -Force
            $outObject  
        } else {
            $r
        }
        
    }
} 

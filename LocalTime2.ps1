$strComputer = "."
 
$colItems = get-wmiobject -class "Win32_LocalTime" -namespace "root\CIMV2" -computername $strComputer
 
foreach ($objItem in $colItems) {
    "Day: " + $objItem.Day
    "Day Of Week: " + $objItem.DayOfWeek
    "Hour: " + $objItem.Hour
    "Milliseconds: " + $objItem.Milliseconds
    "Minute: " + $objItem.Minute
    "Month: " + $objItem.Month
    "Quarter: " + $objItem.Quarter
    "Second: " + $objItem.Second
    "Week In Month: " + $objItem.WeekInMonth
    "Year: " + $objItem.Year
}

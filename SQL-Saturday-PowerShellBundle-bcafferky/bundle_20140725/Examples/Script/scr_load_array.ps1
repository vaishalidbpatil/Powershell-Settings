#  Author:  Bryan Cafferky   2013-12-15
#
# Purpose:  Demo looping and arrays.
#
#     

$a = ''

# Note:
#    - use of escape sequence to get Carriage Return and Line Feed.
#    - simple loop construct.
#    - $_ to get defaul outout of piping
#    - Annonomous script block between { }

1..100 | % {
    $a+=[Array] $_ + "`r`n"
}

Write-Host $a

# $a | out-file ".\test.txt"

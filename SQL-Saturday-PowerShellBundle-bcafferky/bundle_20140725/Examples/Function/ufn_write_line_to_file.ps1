$s = "this is a line"

1..10000 | % {
     $s >> ".\test.txt"
} 
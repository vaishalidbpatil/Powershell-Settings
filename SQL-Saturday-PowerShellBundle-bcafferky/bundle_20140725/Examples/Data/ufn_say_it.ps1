
# Author:  Bryan Cafferky      Date:  2013-11-29
# 
# Purpose:  Speaks the input...
#
#

function ufn_say_it([string] $speakit)
{ 
#  Fun using SAPI - the text to speech thing....    

$speaker = new-object -com SAPI.SpVoice

$speaker.Speak($speakit, 1) | out-null

}

# Example Call:
#                 ufn_say_it 'Good day to you!'  







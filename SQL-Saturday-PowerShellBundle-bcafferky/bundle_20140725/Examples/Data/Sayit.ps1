
#  Fun using SAPI - the text to speech thing....    

$speaker = new-object -com SAPI.SpVoice

$speakit = Read-Host "Enter what you want me to say: "
$speaker.Speak($speakit, 1) | out-null


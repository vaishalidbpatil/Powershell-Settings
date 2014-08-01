#start a transcript session
$TempDate = Get-Date
$TranscriptFile = "C:\Users\JR286576\Documents\WindowsPowershell\Transcripts\PoshTranscript" `
                  + $TempDate.Year + $TempDate.Month.ToString("00") + $TempDate.Day.ToString("00")
if (Test-Path ($TranscriptFile+".txt")) {
  $ctr = 0
  do { $ctr ++ } while ( Test-Path ($TranscriptFile+"-"+$ctr.ToString("00")+".txt") )
  # $ctr++
  $TranscriptFile += "-"+$ctr.ToString("00")+".txt" 
} else {
  $TranscriptFile += ".txt" 
}
echo "Transcript will be started in: $TranscriptFile"
Start-Transcript $TranscriptFile | Out-Null
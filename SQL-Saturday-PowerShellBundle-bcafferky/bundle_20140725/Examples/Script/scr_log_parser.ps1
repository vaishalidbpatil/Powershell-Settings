set-alias logparser "C:\Program Files (x86)\Log Parser 2.2\LogParser.exe"

start-process -NoNewWindow -FilePath logparser -ArgumentList @"
"SELECT * INTO dbo.PersonTry1 FROM C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\PersonData.txt" -i:CSV -o:SQL -server:"localhost" -database:adventureworks -driver:"SQL Server" -createTable:ON

"@
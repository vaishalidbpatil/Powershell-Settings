<#@{ FullFolderName = "C:\Dev"
    Tail = "Dev"
    Frequency = "0"
    LastAccessed = "03/07/13 09:24:13"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData
#>
@{ FullFolderName = "C:\dev\yeoman"
    Tail = "yeoman"
    Frequency = "6"
    LastAccessed = "03/07/13 08:54:13"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData

@{ FullFolderName = "C:\Users\jr286576\documents\WindowsPowerShell"
    Tail = "WindowsPowerShell"
    Frequency = "9"
    LastAccessed = "03/07/13 08:44:13"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData

@{ FullFolderName = "C:\Users\jr286576"
    Tail = "jr286576"
    Frequency = "1"
    LastAccessed = "03/07/13 18:54:13"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData

@{ FullFolderName = "C:\dev\yoapp"
    Tail = "yoapp"
    Frequency = "12"
    LastAccessed = "03/07/13 19:25:32"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData

@{ FullFolderName = "C:\Users\jr286576\Documents\Visual Studio 2010\Projects\HFNY"
    Tail = "HDNY"
    Frequency = "3"
    LastAccessed = "03/07/13 15:54:13"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData

@{ FullFolderName = "C:\Users\jr286576\documents\WindowsPowerShell\Modules"
    Tail = "Modules"
    Frequency = "11"
    LastAccessed = "03/07/13 21:25:31"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData

@{ FullFolderName = "C:\users\jr286576\downloads"
    Tail = "downloads"
    Frequency = "6"
    LastAccessed = "03/07/13 08:54:13"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData

@{ FullFolderName = "C:\dev\mongoLS"
    Tail = "mongoLS"
    Frequency = "6"
    LastAccessed = "03/07/13 08:54:13"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData

@{ FullFolderName = "C:\users\jr286576\documents\WindowsPowerShell\mosh"
    Tail = "mosh"
    Frequency = "1"
    LastAccessed = "03/07/13 08:52:54"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData

@{ FullFolderName = "C:\users\jr286576\documents\WindowsPowerShell\mosh\src"
    Tail = "src"
    Frequency = "1"
    LastAccessed = "03/07/13 08:53:38"
 } | New-MdbcData -Id {$_.Id} -Property FullFolderName, Tail, Frequency, LastAccessed | Add-MdbcData

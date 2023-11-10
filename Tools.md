# Version Control

### WinMerge as a diff tool (Visual Studio format)
    C:\Program Files\WinMerge\WinMergeU.exe /e /x /u /dl %6 /dr %7 %1 %2

### WinMerge as a diff tool (git format)
    C:\Program Files\WinMerge\WinMergeU.exe -e -x -u "$LOCAL" "$REMOTE"

### WinMerge as a merge tool (Visual Studio format)
    C:\Program Files\WinMerge\WinMergeU.exe /e /x /u /dl %6 /dr %7 %1 %2 %4
 
### p4merge as a merge tool (git format)
    C:\Program Files\Perforce\p4merge.exe "$LOCAL" "$REMOTE"

# Web Development

### Force a proxy to Fiddler in .NET config file
    <system.net>
      <defaultProxy>
        <proxy proxyaddress="http://127.0.0.1:8888" />
      </defaultProxy>
    </system.net>

### ASP.NET Precompile a web site
    aspnet_compiler.exe -v /WebsiteName
    aspnet_compiler.exe -p "C:\Projects\PathToWebsite\." -v /WebsiteName
    aspnet_compiler.exe -p "$(ProjectDir)." -v /$(ProjectName)
- C:\Windows\Microsoft.NET\Framework\v2.0.50727\aspnet_compiler for .NET 2
- C:\Windows\Microsoft.NET\Framework\v4.0.30319\aspnet_compiler for .NET 4

## LogParser

### Examples
    LogParser.exe "select c-ip, TO_LOCALTIME(TO_TIMESTAMP(date, time)) AS LocalTime from $path where time > '13:00:00'"
    LogParser.exe "select c-ip as IP_Address, sc-status AS HTTP_Status_Code, count(*) as Count INTO accessByIp.csv from \\server\path\log.log group by c-ip, sc-status"
    LogParser.exe "select TO_LOCALTIME(TO_TIMESTAMP(date, time)) AS LocalTime, sc-status, time-taken, cs-uri-stem INTO out.csv from 'log with spaces.log'"

### Fields

    - date - Date (UTC), useful for filtering but the file is already probably single day
    - time - UTC Time, simplest for querying, e.g. `time > '13:00:00'` (after 1 PM UTC)
      - `TO_LOCALTIME(TO_TIMESTAMP(date, time)) AS LocalTime` - Displays time & date converted to local TZ
    - cs-uri-stem - URL path
    - cs-uri-query - query string, useful to filter on if doing a dye trace
    - c-ip - Client IP
    - cs(User-Agent) - UA string, often very long
    - cs-host - host name, useful to filter on a multi-tenant site
    - sc-status - HTTP status code
    - sc-bytes - response bytes (server-to-client)
    - cs-bytes - request bytes (client-to-server)
    - time-taken - request/response time, in milliseconds

### Flags

    - `-stats:OFF` - disable stats at the end
    - `-q:ON` - quiet mode (don't page, display all results)

### Aggregate
    $logs = ls -Filter *.log
    $logs | % { LogParser.exe "select '$($_.name)' as file, time-taken, TO_LOCALTIME(TO_TIMESTAMP(date, time)) AS LocalTime INTO $($_.name).csv from '$($_.name)' where time > '00:45:00'" }
    $logs | % { get-content "$($_.name).csv" | Add-Content CombinedLogs.csv }

# Windows

### See why computer recent went to sleep
    powercfg -lastwake

### Disable hibernate
    powercfg /h off

### Allow aliased local host to accept windows authentication

    New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0\ -Name 'BackConnectionHostNames' -Value ([string[]]('devlocal')) -PropertyType 'MultiString'
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0\ -Name 'BackConnectionHostNames' -Value ([string[]]('dev-sql','devlocal'))

### Special characters keyboard shortcuts
- Zero-width breaking space: Alt+08203
- Non-breaking space: Alt+0160
- Section symbol: Alt+0167 (§)
- Up Triangle: Alt+ +25B2  (&#9650; ▲)
- Right Triangle: +, 2, 5, B, A (&#9658; ►)
- Down Triangle: +, 2, 5, B, C (&#9660; ▼)
- Left Triangle: +, 2, 5, C, 4 (&#9664; ◄)

### Silent procmon monitor
    procmon /NoConnect /AcceptEula
    procmon /BackingFile C:\procmondata.pml /AcceptEula /Minimized /Quiet
... let it run ...
    procmon /Terminate
    procmon /Quiet /OpenLog C:\procmondata.pml

### Symlink for SQL templates
    mklink /D "C:\PathToSqlTemplates\AAA Matt Templates" "C:\PathTo\My SQL Templates"

### Symlink for SQL templates via Powershell
    New-Item -ItemType Junction -Path "C:\Users\MyUsername\AppData\Roaming\Microsoft\SQL Server Management Studio\VersionNumber\Templates\Sql\AAA_MyTemplates" -Target "C:\Users\MyUsername\OneDrive - My Company\Documents\SQL Queries"

### Allow UAC to have admin access to file explorer
    [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
    "EnableLinkedConnections"=dword:00000001
then restart

### Host a wifi hot spot
    netsh wlan set hostednetwork mode=allow ssid="MLH LT" key="GreatPassword"
    netsh wlan start hostednetwork
    netsh wlan show hostednetwork

### Allow non-admin user to restart a service
    subinacl.exe /service MyService /GRANT=MyServiceControlUser=STOE

# PowerShell

### Schedule a PowerShell Task
- Action: Start a program
- Script: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
- Arguments: `-NonInteractive -Command "& .\MainScript.ps1 params"`
- Starts in: `C:\PathTo\RelativeReference`

### Enable remoting on server
    get-service winrm # Verify it is running
    Enable-PSRemoting -force

### Start interactive session
    Enter-PsSession server

### Give permissions to a specific non-admin user
    Set-PSSessionConfiguration microsoft.powershell -ShowSecurityDescriptorUI

...give the user/group Invoke permission and click OK...

    Restart-Service winrm

### Search for a phrase inside files in a directory structure
    Get-ChildItem -Recurse | Select-String 'str'

### View all values of an enum
    [enum]::GetValues([System.Text.RegularExpressions.RegexOptions]) | % { "$($_): $([int]$_)" }

### Convert ascii formatted hex string ('0xd5a2') to byte array
    [regex]::Matches($b.replace("0x",""), "..") | % { [byte]::Parse($_, 515) }

### Ascii text to hex string
    ("A:B" | % { [system.text.encoding]::UTF8.GetBytes($_) } | % { "{0:x2}" -f $_ }) -join ''

### Powershell byte array to hex string ($b is the byte array)
    $b | % { "{0:x2}" -f $_ } | Join-String -Separator ''
    "0x" + [string]::Join("", $($b | % { "{0:X2}" -f $_ }))
    $b.FromBase64() | % { "{0:x2}" -f $_ } | Join-String -Separator ''

### Powershell file to byte array to hex string
    (Get-Content .\binary.bin -AsByteStream | % { "{0:x2}" -f $_ }) -join '' | Set-Clipboard
    (Get-Content .\Ponzi.jpg -AsByteStream | % { "0x{0:x2}" -f $_ }) -join ', '  | Set-Clipboard

### Byte array directly to ascii characters
    $b | % { [Convert]::ToChar($_) } | Join-String -Separator ''
    [system.text.encoding]::UTF8.GetString($b)

### Byte array to file
    [regex]::Matches($a.replace("0x",""), "..") | 
        % { [byte]::Parse($_, 515) } | 
        Set-Content C:\out.xlsx -AsByteStream

### Base64 directly to binary file
    set-content -value $a.FromBase64() -AsByteStream -Path C:\x.png

### String to binary byte array (UTF8)
    [system.text.encoding]::UTF8.GetBytes($a)

### Get a random array of numbers
    (Get-Random $(0..255) -Count 16 | % { "{0:x2}" -f $_ }) -join '' | Set-Clipboard

### Create a self-signed certificate
    New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "testdomain.local" -FriendlyName "testdomain" -NotAfter (Get-Date).AddYears(10)

# Robocopy

### Common flags
    robocopy source destination /MIR /Z /LOG+:C:\robocopy.log /TEE /NDL /NJH /NP
- /L = to test
- /MIR = recurse+empty dir+purge 
- /Z = restartable mode
- /LOG+ = log to a file in append mode
- /TEE = also to console 
- /NFL = don't log file name
- /NDL = don't log directory
- /NJH = No job header
- /NJS = No job summary
- /NP = No Progress
- /XF = Exclude file
- /XD = Exclude directory
- /XJ = Skip junctions (sym links)

### Backup local files (backup.cmd)
    @echo off
    robocopy %userprofile%\Documents\ H:\LocalBackup\MyDocs /MIR /XJ /NFL /NDL /NJH /NJS /r:3 /w:5 /XF %userprofile%\Documents\desktop.ini
    copy /Z /Y C:\Local\ConnectionStrings.Config H:\LocalBackup\

### Region copy (for speed with many files)
_XO XC XN XX: only inlcude lonely files_

    robocopy \\prod\source \\stage\destination /S /XO /XC /XN /XX /LOG:C:\robo.log /TEE

# Other

## pdftk

### Combine multiple files into one
    pdftk doc1.pdf doc2.pdf doc3.pdf cat output merged.pdf

### Rotate clockwise
    pdftk in.pdf cat 1-endeast output rotatedclockwise.pdf

### Rotate counterclockwise
    pdftk in.pdf cat 1-endwest output rotatedcounterclockwise.pdf

### Split multi page into single page PDFs
    pdftk in.pdf burst

### Remove a single page
    pdftk in.pdf cat 1-12 14-end output out1.pdf

## SQL Profiler
### AppDev template
- Events:
  - Stored Procedures\RPC:Completed
  - TSQL\SQL:BatchCompleted
- Columns:
  - ApplicationName
  - CPU
  - DatabaseName
  - Duration
  - EndTime
  - Error
  - HostName
  - LoginName
  - Reads
  - SPID
  - StartTime
  - TextData
  - Writes
- Order:
  - EventClass
  - SPID
  - DatabaseName
  - HostName
  - ApplicationName
  - LoginName
  - TextData
  - StartTime
  - EndTime
  - CPU
  - Duration
  - Reads
  - Writes
  - Error
- Column Filters:
  - ApplicationName not like 'Microsoft SQL Server Management Studio - %', 'SQLAgent%'
  - TextData not like 'exec sp_reset_connection'
  - DatabaseName not like 'master', 'ssisdb'
- Other items of interest: 
  - Filter - Application Name - like '%.net%', '%internet information services%',
  - Events - Security Audit - Audit Login

## Visual Studio Code

### Force a tab size on ctrl-K, ctrl-D
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "editor.detectIndentation": false

## Expresso

### Express Registration registry key for Expresso
    Windows Registry Editor Version 5.00

    [HKEY_CURRENT_USER\Software\Ultrapico\Expresso]
    "UserName"="Removed for Licensing Purposes"
    "RegistrationCode"="EECF 693C 4B20"


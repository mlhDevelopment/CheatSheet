# Save to $PROFILE.AllUsersAllHosts (the Profile.ps1 file)

# Prompts
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme C:\etc\GitHub\CheatSheet\custom-ys-omptheme.json

# Shortcuts
Set-Alias npp "C:\Program Files\Notepad++\notepad++.exe"
Set-Alias mo Measure-Object
Remove-Alias diff -Force -EA SilentlyContinue
Set-Alias diff 'C:\Program Files\WinMerge\WinMergeU.exe'

function gitmergeall {
  git mergetool --gui .
  write-host "Consider cleaning the following:" -ForegroundColor Yellow
  git clean -n
}

function ShowUrlParts([string]$Url) {
  write-verbose $Url
  $Uri = [Uri]$Url
	
  Write-Output $Uri.GetLeftPart([System.UriPartial]::Path)
	
  $qsParts = [system.web.httputility]::ParseQueryString($Uri.Query)
  $qsParts | % { Write-Output ("  {0}={1}" -f $_, $qsParts[$_] ) }
}

function Monitor-Website([string]$url, [int]$sleep = 3) {
  $i = 0
  while ($true) { 
    [int]$result = $(curl -k -s -f -w "%{http_code}" $url -o C:\Monitor-Website.temp)
    $color = [System.ConsoleColor]::Green
    if ($result -eq 200) {
      $color = [System.ConsoleColor]::White
    }
    elseif ($result -ge 500) {
      $color = [System.ConsoleColor]::Red
    }
    elseif ($result -ge 400) {
      $color = [System.ConsoleColor]::DarkMagenta
    }
    elseif ($result -lt 200) {
      $color = [System.ConsoleColor]::Yellow
    }

    write-host -ForegroundColor $color "$result".PadLeft([math]::round(1 - [math]::cos([math]::PI/25 * $i), 1) * 10, ' ')
    $i += 1
    Start-Sleep $sleep
  }
}

# Preferences
$VerbosePreference = "Continue"

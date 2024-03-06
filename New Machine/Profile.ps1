# Save to $PROFILE.AllUsersAllHosts (the Profile.ps1 file)

# Prompts
Import-Module posh-git
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\thecyberden.omp.json" | Invoke-Expression

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

function Monitor-Website([string]$url, [int]$sleep = 3, [string]$TestForContent = '') {
  # Output legend
  Write-Host -ForegroundColor Yellow '100 ' -NoNewline;
  Write-Host -ForegroundColor White '200 ' -NoNewline;
  Write-Host -ForegroundColor Green '200+ ' -NoNewline;
  Write-Host -ForegroundColor Yellow '300 ' -NoNewline;
  Write-Host -ForegroundColor DarkMagenta '400 ' -NoNewline;
  Write-Host -ForegroundColor Red '500'

  $i = 0
  while ($true) { 
    $responseTime = (Measure-Command -Expression { 
      $response = Invoke-WebRequest $url -SkipCertificateCheck -MaximumRedirection 0 -SkipHttpErrorCheck -Verbose:$false
    }).TotalMilliseconds
    
    $color = [System.ConsoleColor]::Green          # 201-299
    if ($response.StatusCode -eq 200) {
      $color = [System.ConsoleColor]::White        # 200
    }
    elseif ($response.StatusCode -ge 500) {
      $color = [System.ConsoleColor]::Red          # 500s
    }
    elseif ($response.StatusCode -ge 400) {
      $color = [System.ConsoleColor]::DarkMagenta  # 400s
    }
    elseif ($response.StatusCode -ge 300) {
      $color = [System.ConsoleColor]::Yellow       # 300s
    }
    elseif ($response.StatusCode -lt 200) {
      $color = [System.ConsoleColor]::Yellow       # 100s
    }

    $contentSuffix = ''
    if('' -ne $TestForContent) {
      if($response.Content.Contains($TestForContent)) {
        $contentSuffix = ' ✓'
      } else {
        $contentSuffix = ' ✗'
      }
    }

    # Make the result dance so we can see it change over time
    $display = "$([math]::Round($responseTime, 0)) ms$contentSuffix"
    $padding = [math]::round(1 - [math]::cos([math]::PI/25 * $i), 1) * 10 + $display.Length
    #$display = "$($response.StatusCode) $([math]::Round($responseTime, 0)) ms"
    
    write-host -ForegroundColor $color $display.PadLeft($padding, ' ')
    $i += 1
    Start-Sleep $sleep
  }
}

# Preferences
$VerbosePreference = "Continue"

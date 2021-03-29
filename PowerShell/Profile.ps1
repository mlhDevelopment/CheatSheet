# Save to $PROFILE.AllUsersAllHosts\Profile.ps1

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
  $files = git diff --name-only --diff-filter=U
  Write-host "Merging changes for:" -ForegroundColor Yellow
  Write-Output $files
  $files | % {
    git mergetool --tool=p4merge $_
  }
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

# Preferences
$VerbosePreference = "Continue"

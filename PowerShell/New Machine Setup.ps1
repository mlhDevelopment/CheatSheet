### Allow scripts May need to be done manually
Set-ExecutionPolicy RemoteSigned

### Colorful git prompts
Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force
Install-Module oh-my-posh -Scope CurrentUser -AllowPrerelease
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck

# Can run Get-PoshThemes to determine which current theme to use, set it in Profile.ps1

### SSMS Templates linked so they are easy to access
function SymlinkForSSMSTemplates([string]$folder) {
    $latestSSMS = gci "C:\Users\matt.howell\AppData\Roaming\Microsoft\SQL Server Management Studio" | ? { $_.Name -match "^\d+\.\d+$" } | Sort-Object CreationTime -Top 1
    cd $latestSSMS
    # \Templates\Sql\AAA_MyTemplates
    New-Item -ItemType SymbolicLink -Path .\Templates\Sql\AAA_MyTemplates -Target $folder
}
SymlinkForSSMSTemplates(prompt)

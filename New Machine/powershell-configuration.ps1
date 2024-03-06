# Powershell-specific setup not covered by winget import
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Powershell Modules
Install-Module -Name posh-git -Scope AllUsers -Repository PSGallery
Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force
Install-Module -Name SqlServer -Scope AllUsers -Repository PSGallery

# SSMS Templates linked so they are easy to access (Run SSMS at least once before running)
$latestSSMS = gci "$env:APPDATA\Microsoft\SQL Server Management Studio" | ? { $_.Name -match "^\d+\.\d+$" } | Sort-Object CreationTime -Top 1
$targetPath = Join-Path $latestSSMS.FullName "Templates\Sql\AAA_MyTemplates"

# Prompt for the path
$templatePath = Read-Host "Path to SSMS Custom Templates"
if($templatePath) {
    New-Item -ItemType SymbolicLink -Path $targetPath -Target $templatePath
}

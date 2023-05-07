### Choco & these packages should already be installed (manually)
choco install -y -notsilent notepadplusplus openssl git

### Other choco installs
winget 
choco install -y -notsilent gitextensions gimp python3 winmerge 
winget install --interactive nodejs postman
choco install -y gnupg pdftk autohotkey 7zip nmap
winget install sysinternals

### Allow scripts May need to be done manually
#Set-ExecutionPolicy RemoteSigned Should already be done before this script can be ran

### Prep for module installs
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

### Colorful git prompts
Install-Module -Name posh-git -Scope AllUsers -AllowPrerelease -Repository PSGallery
winget install JanDeDobbeleer.OhMyPosh -s winget
oh-my-posh init pwsh --config custom-ys-omptheme.json

### Install other modules
Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force
Install-Module -Name SqlServer -Scope AllUsers -Repository PSGallery


### SSMS Templates linked so they are easy to access (Run SSMS at least once before running)
$latestSSMS = gci "$env:APPDATA\Microsoft\SQL Server Management Studio" | ? { $_.Name -match "^\d+\.\d+$" } | Sort-Object CreationTime -Top 1
cd $latestSSMS

# Prompt for the path
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
$dialog.Description = "Folder to symlink to SSMS 'AAA_MyTemplates'"
$dialog.UseDescriptionForTitle = $true

if($dialog.ShowDialog() -eq 'OK') {
    New-Item -ItemType SymbolicLink -Path .\Templates\Sql\AAA_MyTemplates -Target $dialog.SelectedPath
}




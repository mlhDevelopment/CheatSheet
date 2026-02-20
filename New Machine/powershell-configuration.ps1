# Powershell-specific setup not covered by winget import
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Powershell Modules
Install-Module -Name posh-git -Scope AllUsers -Repository PSGallery
Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force
Install-Module -Name SqlServer -Scope AllUsers -Repository PSGallery


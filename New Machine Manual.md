# Pre-script steps
*Run these so that you can run New Machine Chocolatey.ps1*
- Relax execution policy
    
      Set-ExecutionPolicy AllSigned

  - Even if you will set it to Unrestricted later, leave as signed until the machine is mostly setup

- Install Chocolatey

      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
      iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

- Install np++, openssl, and git through Chocolatey
  
      choco install -y -notsilent notepadplusplus openssl git

- Clone personal repositories

      mkdir C:\etc\github

# Other setup steps
*Things not automated by PowerShell (see PowerShell\New Machine \*.ps1) that can be ran independently of the setup steps*
- Install Powershell 7
- Install Windows Terminal from the Windows Store
- Download FantasqueSansMono font from https://www.nerdfonts.com/font-downloads
  - Then update custom font for Windows Terminal in the settings profiles.defaults.fontFace:FantasqueSansMono
- Migrate Outlook signature
- Migrate Windows features & settings
- Upgrade bios and update bios settings


## Install self-updating & paid apps
- Firefox Developer Edition
- Visual Studio
- Visual Studio Code (Windows Store)
- SSMS
- SQL Dev Edition
- SSMS Tool Kit
- Printer/scanner driver


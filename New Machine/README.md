# Pre-script steps
*Run these so that you can run New Machine winget.ps1*
- Relax execution policy
    
      Set-ExecutionPolicy AllSigned

  - Even if you will set it to Unrestricted later, leave as signed until the machine is mostly setup

- Install packages through winget (see `New Machine winget.ps1`)
  
- Clone personal repositories

      mkdir C:\etc\GitHub

# Other setup steps
*Things not automated by PowerShell (see PowerShell\New Machine \*.ps1) that can be ran independently of the setup steps*
- Install Powershell 7
- Install Windows Terminal from the Windows Store
- Download FantasqueSansMono font from https://www.nerdfonts.com/font-downloads aka https://github.com/ryanoasis/nerd-fonts/releases
  - Install FantasqueSansMNerdFont-Regular.ttf for all users
  - Then update custom font for Windows Terminal in the settings profiles.defaults.font.face:"FantasqueSansM Nerd Font"
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


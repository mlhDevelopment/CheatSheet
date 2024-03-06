# Setting up a new machine (personal or professional)

## Pre-script steps

Run these so that you can run New Machine winget.ps1

- Relax execution policy

    Set-ExecutionPolicy AllSigned

  - Even if you will set it to Unrestricted later, leave as signed until the machine is mostly setup

- Clone this repository to use setup scripts

      mkdir C:\etc\GitHub
      git clone CheatSheet.git

- Install packages through winget

  1. Import standard tools (`winget import winget-apps.json`)
  2. Export from prior machine (`winget export -o winget.json`) and import (`winget import winget.json`)
  3. Install manually as needed (useful commands are search, show, install, list; always use --id parameter)
  4. Whatever you choose, review the list before importing (did you want that version of Python?)
  
- Configure PowerShell (`powershell-configuration.ps1`)
- Update PowerShell Profile (see `profile.ps1` for instructions)

## Other setup steps

Things not automated by PowerShell (see PowerShell\New Machine \*.ps1) that can be ran independently of the setup steps

- Download FantasqueSansMono font from [NerdFonts](https://www.nerdfonts.com/font-downloads) ([direct link](https://github.com/ryanoasis/nerd-fonts/releases))
  - Install FantasqueSansMNerdFont-Regular.ttf for all users
  - Then update custom font for Windows Terminal in the settings profiles.defaults.font.face:"FantasqueSansM Nerd Font"
- Migrate Outlook signature
- Migrate Windows features & settings
- Upgrade BIOS and update BIOS settings
- Apply Windows updates and vendor driver updates

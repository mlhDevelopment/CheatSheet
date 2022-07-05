# Configuration

## Basic

### Required gloabl configs
    git config --global user.name 'Matt Howell'
    git config --global user.email 'mhowell@work.com'

### Set Notepad++ as the default editor
    git config --global core.editor \"C:/Program Files/notepad++/notepad++.exe\" -multiInst -nosession

### Set P4 as merge tool (Needed??)
    git config --global mergetool.p4merge.path 'C:/Program Files/Perforce/p4merge.exe'
    git config --global mergetool.p4merge.cmd 'p4merge.exe \"$BASE\" \"$LOCAL\" \"$REMOTE\" \"$MERGED\"'
    git config --global merge.tool p4merge
    git config --global merge.guitool p4merge


### Set WinMerge as diff tool
    git config --global difftool.winmerge.path 'C:/Program Files/WinMerge/winmergeu.exe'
    git config --global difftool.winmerge.cmd 'C:/Program Files/WinMerge/winmergeu.exe -e -x -u \"$LOCAL\" \"$REMOTE\"'
    git config --global diff.tool winmerge
    git config --global diff.guitool winmerge

### Edit config file in an editor
    git config --global --edit

## Advanced

### Local config overrides (e.g. for github access)
    git config --local user.name 'Matt Howell'
    git config --local user.email 'mlhDevelopment@gmail.com'

### Enable auto-pruning on fetch or pull (current repo only)
    git config remote.origin.prune true

### Enable reuse recorded resolution
    git config --global rerere.enabled true

### Set default new branch to main
    git config --global init.defaultBranch main
	
### Set default pull to do a rebase on mutual changes
    git config --global pull.rebase true

# Remote Management

### View remote repositories
    git remote -v

### Add remote (e.g. alternative origin)
    git remote add upstream https://github.com/USER/REPRO.git

### Add a remote tracking branch
    git push -u origin branchname

### Remove a tracking branch link
    git branch --unset-upstream

### Delete a remote branch
    git push origin --delete branchname

### Get upstream changes without merging them in
    git fetch
    git fetch upstream
    git fetch --all

## Recover

### View internal, untracked references (reset hard fail)
    git reflog show

Useful after a `git reset --hard` but you lost some changes. Find the change you need to recover, switch to it (`git checkout 'HEAD@{4}'`) 
and if it is what you need to recover, create a branch (`git switch -c pivot`).

# Repo Maintenance

### Git command with repo as parameter
    git -C .\sub\ status -s

### List status in multiple repos
    gci C:\projects\ -Directory | `
        ? { Test-Path @($_.FullName, ".git") } | `
        % { $changes = git -C $_.FullName status -s; if($changes.length -gt 0) { $_.FullName; $changes } }

### Fetch in multiple repos
    gci C:\projects\ -Directory | % { git -C $_.FullName fetch --all }

### Undo - discard all adds (A) from working dir
    git clean -f

### Undo - discard all changes (M) from working dir
    git restore .

### Undo - discard a change from stage index
    git restore --staged */myfile.ts

### Remove all files not in source control (scorch - use carefully)
    git clean -xdf

### See what files should have been ignore (e.g. after gitignore update)
    git rm --cached -r .
    git add .

# Azure Devops

## Configuration

### Sign in to azure commandline using username & password
    az login

### Install the devops extension
    az extension add --name azure-devops

### Set a default organization and project
    az devops configure --defaults organization=https://dev.azure.com/contoso project=ContosoWebApp

## Pull Requests

### List pull requests
    az repos pr list

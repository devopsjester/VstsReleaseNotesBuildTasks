function Get-WikiFromGit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$TargetFolder
    )

    $WikiFolder = "$TargetFolder\Wiki"
    Write-Verbose "Setting up $WikiFolder as the local copy of the wiki repository."
    # Save current location, so that we can return to it later
    
    if (Test-Path $WikiFolder) {
        Write-Verbose "$WikiFolder exists - removing it prior to initialization"
        Remove-Item -Path $WikiFolder -Recurse -Force
    }

    mkdir $WikiFolder
    Push-Location
    Set-Location $WikiFolder
    Write-Verbose "Set location at $WikiFolder."

    git init; Write-Verbose "Initialized git repo"
    git remote add origin $Uri ; Write-Verbose "add origin to $Uri"
    git config gc.auto 0 ; Write-Verbose "Disabled garbage collection."
    git pull ; Write-Verbose "Pulled wiki content to local repo."

    Pop-Location
    
    Write-Output $WikiFolder
}

function Get-FileName {
    param (
        [Parameter(Mandatory=$true)][System.Io.FileInfo]$File
    )

    $File.Name.Replace($File.Extension, [string]::Empty)
}
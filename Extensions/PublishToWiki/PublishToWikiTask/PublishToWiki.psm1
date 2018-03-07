function Get-WikiFromGit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$WikiFolder
    )

    Write-Verbose "Setting up $WikiFolder as the local copy of the wiki repository."
    # Save current location, so that we can return to it later
    
    if (Test-Path $WikiFolder) {
        Write-Verbose "$WikiFolder exists - removing it prior to initialization"
        Remove-Item -Path $WikiFolder -Recurse -Force
    }

    mkdir $WikiFolder
    Push-Location
    $userName = $env:BUILD_REQUESTEDFOR
    $pat = $env:SYSTEM_ACCESSTOKEN
    #git clone $Uri $WikiFolder
    #Write-Verbose "Cloned repo to $WikiFolder."

    Set-Location $WikiFolder
    Write-Verbose "Set location at $WikiFolder."

    git init; Write-Verbose "Initialized git repo"
    git remote add origin $Uri ; Write-Verbose "add origin to $Uri"
    git config gc.auto 0 ; Write-Verbose "Disabled garbage collection."
    git config user.name $env:BUILD_REQUESTEDFOR; Write-Verbose "Build requested for $env:BUILD_REQUESTEDFOR"
    git config user.email $env:BUILD_REQUESTEDFOREMAIL; Write-Verbose "email address: $env:BUILD_REQUESTEDFOREMAIL"
    git config http.extraheader "AUTHORIZATION: bearer $env:SYSTEM_ACCESSTOKEN"; Write-Verbose "Set authorization to PAT"
    git pull origin wikiMaster -q; Write-Verbose "Pulled wiki content to local repo."
    
    git branch --set-upstream-to=origin/wikiMaster master; Write-Verbose "Set upstream to master"

    Pop-Location
    Write-Verbose "This is what is going to be in WikiFolder = [$WikiFolder]."
    Write-Output $WikiFolder
}

function Get-FileName {
    param (
        [Parameter(Mandatory=$true)][System.Io.FileInfo]$File
    )

    $File.Name.Replace($File.Extension, [string]::Empty)
}
function Get-WikiFromGit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Uri
    )

    $PublishToWikiTaskGuid = "cfbe4a47-dabf-45af-a0e4-978f6e86ec75"
    $WikiFolder = "$env:BUILD_BINARIESDIRECTORY\$PublishToWikiTaskGuid\Wiki"

    # Save current location, so that we can return to it later
    
    if (Test-Path $WikiFolder) {
        Remove-Item -Path $WikiFolder -Recurse -Force
    }

    mkdir $WikiFolder
    Push-Location
    Set-Location $WikiFolder
    
    git init $WikiFolder
    git remote add origin $Uri
    git config gc.auto 0
    git config --get-all http.$Uri.extraheader
    git -c http.extraheader="AUTHORIZATION: bearer $env:SYSTEMACCESSTOKEN" fetch --tags --prune --progress --no recurse-submodules origin
    git checkout --progress --force master
    git config http.extraheader="AUTHORIZATION: bearer $env:SYSTEMACCESSTOKEN"

    Pop-Location
    
    Write-Output $WikiFolder
}

function Get-FileName {
    param (
        [Parameter(Mandatory=$true)][System.Io.FileInfo]$File
    )

    $File.Name.Replace($File.Extension, [string]::Empty)
}
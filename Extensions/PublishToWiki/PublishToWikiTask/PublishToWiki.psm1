function Get-WikiFromGit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$false)][string]$TargetFolder = '.'
    )

    # Save current location, so that we can return to it later
    
    if (Test-Path "$TargetFolder\Wiki") {
        Remove-Item -Path "$TargetFolder\Wiki" -Recurse -Force
    }

    Push-Location
    Set-Location $TargetFolder
    git clone $Uri Wiki
    Pop-Location
    
    Write-Output "$TargetFolder\Wiki"
}

function Get-FileName {
    param (
        [Parameter(Mandatory=$true)][System.Io.FileInfo]$File
    )

    $File.Name.Replace($File.Extension, [string]::Empty)
}
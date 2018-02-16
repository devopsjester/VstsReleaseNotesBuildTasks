[CmdletBinding()]
param ()

$PathToFile = Get-VstsInput -Name PathToFile -Require
$WikiUrl = Get-VstsInput -Name WikiUrl -Require
$File = Get-VstsInput -Name File -Require

# Set a flag to force verbose as a default
$VerbosePreference = 'Continue'

Import-Module -Name "$PSScriptRoot\PublishToWiki.psm1" -Force

# Get the build and release details
$collectionUrl = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$teamproject = $env:SYSTEM_TEAMPROJECT
$binariesDirectory = $env:BUILD_BINARIESDIRECTORY

Write-Verbose "collectionUrl = [$collectionUrl]"
Write-Verbose "teamproject = [$teamproject]"
Write-Verbose "binariesDirectory = [$binariesDirectory]"
Write-Verbose "PathToFile = [$PathToFile]"
Write-Verbose "WikiUrl = [$WikiUrl]"
Write-Verbose "File = [$File]"

$localWikiPath = Get-WikiFromGit -Uri $WikiUrl -TargetFolder $binariesDirectory
Write-Verbose "Cloning Wiki repository to $localWikiPath."

$targetPath = "$localWikiPath\$PathToFile"
mkdir $targetPath -ErrorAction SilentlyContinue

Copy-Item -Path $File -Destination $targetPath
$fileName = Get-FileName -File $File
Write-Verbose "Copied $fileName from $File to $targetPath"

Push-Location
Set-Location $targetPath

Get-ChildItem *.md | ForEach-Object { ([System.Io.FileInfo]$_).BaseName } | Set-Content .order
Write-Verbose "Updated $targetPath/.order file."

$releaseTOCPath = $PathToFile -split '/' | Select-Object -Last 1
$releaseTOCFileName = "$targetPath/../$releaseTOCPath.md"
$releaseNote = "`n[$fileName]($PathToFile/$fileName)"
$releaseNote | Add-Content "$releaseTOCFileName"
Write-Verbose "Added release note link ($releaseNote) to $releaseTOCFileName."

Set-Location $localWikiPath
git add .
git commit -m "PublishToWiki task: Updated release notes in wiki"
git push
Pop-Location
Write-Verbose "Updated wiki in VSTS."



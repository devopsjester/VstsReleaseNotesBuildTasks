[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="The path from the root wiki page to where the new page should be located")]
    [string]$PathToFile,

    [Parameter(Mandatory=$true, HelpMessage="The URL of the Git repository that holds the project's wiki")]
    [string]$WikiUri,

    [Parameter(Mandatory=$true, HelpMessage="The markdown file to be uploaded to the project's wiki")]
    [string]$File
)

# Set a flag to force verbose as a default
$VerbosePreference = 'Continue'

Import-Module -Name "$PSScriptRoot\PublishToWiki.psm1" -Force

# Get the build and release details
$collectionUrl = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$teamproject = $env:SYSTEM_TEAMPROJECT

Write-Verbose "collectionUrl = [$collectionUrl]"
Write-Verbose "teamproject = [$teamproject]"
Write-Verbose "PathToFile = [$PathToFile]"
Write-Verbose "WikiUri = [$WikiUri]"
Write-Verbose "File = [$File]"

$localWikiPath = Get-WikiFromGit -Uri $WikiUri -TargetFolder "~\temp\pubWiki"
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



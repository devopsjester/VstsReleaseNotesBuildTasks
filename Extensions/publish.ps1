param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Folder,
    $Token
)

process {
    # Remove existing package
    Remove-Item $Folder\*.vsix
    
    # Package
    tfx extension create --manifest-globs vss-extension.json --root $Folder --output-path $Folder
    
    # Get package name
    $vsix = (Get-ChildItem "$Folder\*.vsix")[0].Name

    #publish package
    #tfx extension publish  --manifest-globs vss-extension.json --root $Folder --vsix $vsix
}
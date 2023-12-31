Clear-Host
Write-Output "!! Welcome !!"

#Get-Content -Path ("~/repos/bible-verses-local/verses/verse-{0}" -f (Get-Random -Minimum 0 -Maximum 99))

function AliasHelper-GetWorkspacesFolder {
    return "~/repos" # Reason: Did not want to set a global variable to avoid variable name collisions with other scripts, but wanted a single point to change the constant
}

function Alias-Search {
    param([string]$SearchTerm)
    [string]$SEARCH_ENGINE = "https://duckduckgo.com/?q="
    start ("{0}{1}" -f $SEARCH_ENGINE, $SearchTerm)
}

function Alias-MkdirInWorkspace {
    param([string]$ProjectName)
    [string]$WORKSPACES_FOLDER = AliasHelper-GetWorkspacesFolder
    mkdir $WORKSPACES_FOLDER/$ProjectName | Set-Location
}

function Alias-GotoWorkspace {
    param([string]$ProjectName)
    [string]$WORKSPACES_FOLDER = AliasHelper-GetWorkspacesFolder
    Set-Location ("{0}/{1}" -f $WORKSPACES_FOLDER, $ProjectName) 
}

function Alias-HelixWorkspace {
    param([string]$ProjectName)
    [string]$CurrentLocation = Get-Location
    Alias-GotoWorkspace $ProjectName
    hx .
    Set-Location ($CurrentLocation)
}

function Alias-CreateSymlink {
    param(
        [string]$Source,
        [string]$Dest
    )
    
    New-Item -ItemType SymbolicLink -Path $Dest -Target $Source
}

function Alias-SpinHTTPServer {
    param([int]$Port)
    py -m http.server $Port
}

function Alias-GitRaw {
    param(
        [string]$Repository,
        [string]$Branch,
        [string]$File,
        [string]$OutFile,
        [Boolean]$Verbose=$false
    )
    
    [string]$Query = "https://raw.githubusercontent.com/{0}/{1}/{2}" -f $Repository, $Branch, $File
    
    if ($Verbose) {
        Write-Host ("Fetch {0}" -f $Query)
    }
    
    [string]$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"
    Invoke-WebRequest -Uri $Query -UserAgent $UserAgent -OutFile $OutFile
}

function Alias-SpinJellyfin {
    [string]$CurrentLocation = Get-Location
    Set-Location ~\jellyfin_10.8.9\
    dotnet jellyfin.dll
    Set-Location ($CurrentLocation)
}

function Alias-OpenDocsGL {
    param(
        [string]$SearchTerm,
        [Parameter(Mandatory=$false)][string]$GLspec="gl3"
    )
    
    [string]$SEARCH_ENGINE = "file:///C:/docsgl/htdocs/"#"https://docs.gl/"
    start ("{0}{1}/{2}.html" -f $SEARCH_ENGINE, $GLspec, $SearchTerm)
}

Set-Alias workspace Alias-GotoWorkspace
Set-Alias symlink Alias-CreateSymlink
Set-Alias spinhttp Alias-SpinHTTPServer
Set-Alias search Alias-Search
Set-Alias workspace-mkdir Alias-MkdirInWorkspace
Set-Alias gitraw Alias-GitRaw
Set-Alias hxin Alias-HelixWorkspace
Set-Alias StartServer-Jellyfin Alias-SpinJellyfin
Set-Alias docsgl Alias-OpenDocsGL
Set-PoshPrompt -Theme huvix
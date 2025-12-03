Clear-Host
Write-Output "!! Welcome !!"

# Fetch Weather in background
$WeatherJob = Start-Job -Name WeatherFetchJob -ScriptBlock {
    (Invoke-RestMethod https://wttr.in/?m) -split "`n" | Select-Object -Skip 1 | Select-Object -SkipLast 33
}

# Output weather once fetching is completed
$null = Register-ObjectEvent -InputObject $WeatherJob -EventName StateChanged -Action {
    if ($Event.SourceEventArgs.JobStateInfo.State -eq "Completed") {
        Clear-Host
        Write-Host "!! Welcome !!"
        Receive-Job -Job $Event.Sender | ForEach-Object { Write-Host $_ }
        Write-Host -NoNewline (prompt)
        Remove-Job -Job $Event.Sender

        Unregister-Event -SourceIdentifier $Event.SubscriptionId
    }
}

# CMake Globals
$env:CC="C:/mingw64/bin/gcc.exe"
$env:CXX="C:/mingw64/bin/g++.exe"
$env:CMAKE_GENERATOR="MinGW Makefiles"

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

function Alias-GetWeather {
    (Invoke-RestMethod https://wttr.in/?m) -split "`n" | Select-Object -Skip 1 | Select-Object -SkipLast 2 | Out-String
}

function Alias-RunProcessing {
    param([string]$ProjectPath)

   & "E:\CS Computer Science Principles\processing\processing-4.3\processing-java.exe" "--sketch=$($ProjectPath)" --run
}

enum GithubRepositoryVisibilityTypes {
    public
    private
}

function Alias-GithubRepositoryInit {
    param(
        [string]$RepoName,
        [GithubRepositoryVisibilityTypes]$Visibility = [GithubRepositoryVisibilityTypes]::public,
        [string]$License = $null,
        [string]$Description = $null,
        [string]$BranchName = "main"
    )

    [string]$Username = gh api user --jq '.login'
    [string]$LicenseFlag = ""
    [String]$DescriptionFlag = ""

    if ($License) {
        if ($BranchName -ne "main") {
            Write-Host "ERROR: Cannot specify license and branch because ``gh`` is really stupid"
            return
        }
    
        if (Test-Path LICENSE) {
            Write-Host "ERROR: Please rename or delete local LICENSE file"
            return
        }
        
        $LicenseFlag = "--license=$License"
    }

    if ($Description) {
        $DescriptionFlag = "--description=$Description"
    }

    & gh repo create $RepoName "--$Visibility" "$LicenseFlag" "$DescriptionFlag"
    & git init
    & git remote add origin "https://github.com/$Username/$RepoName.git"
    & git branch -M $BranchName

    if (!(Test-Path README.md)) {
        "# $RepoName`n" | Out-File -FilePath "README.md" 
    }
    
    & git add README.md
    & git commit -m "Initial Commit"

    if ($License) {
        # why this works. why should i know
        Write-Host "WARNING: Fatal error below intentional"
        & git pull origin $BranchName
        git merge --allow-unrelated-histories FETCH_HEAD    
        & git pull origin $BranchName
    }
    
    & git push -u origin $BranchName
}

function Check-Corruption {
    param(
        [string]$Location = "."
    )

    [string]$CurrentLocation = Get-Location
    [Boolean]$FoundCorruption = $false

    foreach ($File in Get-ChildItem) {
        if ($File.Length -lt 1) {
            [System.ConsoleColor]$fc = $host.UI.RawUI.ForegroundColor # save color
            $host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::red # set new color
            
            Write-Host ("Possible corruption found! Affected file: $($File.Name)")
            
            $host.UI.RawUI.ForegroundColor = $fc # reset color
            $FoundCorruption = $true            
        }
    }

    if (!$FoundCorruption) {
        Write-Host ("No corruption found")
    }
}

function Shutdown-WSL {
    wsl --shutdown
    gsudo sc.exe stop WSLService
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
Set-Alias weather Alias-GetWeather
Set-Alias pjava Alias-RunProcessing
Set-Alias ghinit Alias-GithubRepositoryInit
Set-PoshPrompt -Theme huvix

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

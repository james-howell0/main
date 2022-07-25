#Define Log Name and Location
$LogPath = "$env:ProgramData\HCC\Logs\"
$ScriptName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $Script:MyInvocation.MyCommand -Leaf)))
$LogLocation = $LogPath + $ScriptName + "-InPrint3-$(Get-Date -Format dd.MM.yyyy).log"

#Define Folder Locations
$SymbolSetLocation = "$env:ProgramData\Widgit\Common Files\Symbol Set Wordlists"
$WidResourcesLocation = "C:\Program Files (x86)\Widgit\WidResources"

#Define Installer Paths
$InstallerPathCore = "$($PSScriptRoot)\core.msi"
$InstallerPathInPrint = "$($PSScriptRoot)\inprint.msi"
$InstallerPathWL = "$($PSScriptRoot)\wordlistmanager.msi"
$InstallerPathResources = "$($PSScriptRoot)\inprint_resources_uk.msi"

#Define Installer Arguments
$ArgumentsCore = "/i `"$InstallerPathCore`" /quiet /norestart"
$ArgumentsInPrint = "/i `"$InstallerPathInPrint`" /quiet /norestart"
$ArgumentsWL = "/i `"$InstallerPathWL`" /quiet /norestart"
$ArgumentsResources = "/i `"$InstallerPathResources`" /quiet /norestart"


#Begin Trascript
Start-Transcript -Path $LogLocation

Write-Information "Starting Script...."


#Install Core MSI
Write-Information "Installing InPrint 3 Core MSI"
try {
    $p = Start-Process "msiexec.exe" -ArgumentList $ArgumentsCore -Wait -PassThru
    Write-Information "Process completed with return code: $($p.ExitCode)"
} catch {
    Write-Error "Process failed to complete with return code: $($p.ExitCode)"
}

#Install InPrint MSI
Write-Information "Installing InPrint 3 InPrint MSI"
try {
    $p1 = Start-Process "msiexec.exe" -ArgumentList $ArgumentsInPrint -Wait -PassThru
    Write-Information "Process completed with return code: $($p1.ExitCode)"
} catch {
    Write-Error "Process failed to complete with return code: $($p1.ExitCode)"
}


#Install WordList MSI
Write-Information "Installing WordList MSI"
try {
    $p2 = Start-Process "msiexec.exe" -ArgumentList $ArgumentsWL -Wait -PassThru
    Write-Information "Process completed with return code: $($p2.ExitCode)"
} catch {
    Write-Error "Process failed to complete with return code: $($p2.ExitCode)"
}


#Install Resources MSI
Write-Information "Installing Resources MSI"
try {
    $p3 = Start-Process "msiexec.exe" -ArgumentList $ArgumentsResources -Wait -PassThru
    Write-Information "Process completed with return code: $($p3.ExitCode)"
} catch {
    Write-Error "Process failed to complete with return code: $($p3.ExitCode)"
}


#Copy Bundle Files

try {
    Copy-Item -Path "$($PSScriptRoot)\BSL Adult.cfwl" -Destination $SymbolSetLocation -Force 
} catch {
    Write-Error "Failed to copy .cfwl file"
}

try {
    Copy-Item -Path "$($PSScriptRoot)\BSL Early Years.cfwl" -Destination $SymbolSetLocation -Force 
} catch {
    Write-Error "Failed to copy .cfwl file"
}

try {
    Copy-Item -Path "$($PSScriptRoot)\graphics" -Destination $WidResourcesLocation -Force -Recurse
} catch {
    Write-Error "Failed to copy graphics folder"
}

try {
    Copy-Item -Path "$($PSScriptRoot)\graphics_co" -Destination $WidResourcesLocation -Force -Recurse
} catch {
    Write-Error "Failed to copy graphics_co folder"
}

#Exit
Write-Information "Exiting with code: $($process.ExitCode)"
exit $process.ExitCode
Stop-Transcript

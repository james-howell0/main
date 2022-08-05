[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $WorkingDirectory
)

#Logging params
$LogPath = "$env:ProgramData\HCC\Logs\"
$ScriptName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $Script:MyInvocation.MyCommand -Leaf)))
$LogLocation = $LogPath + $ScriptName + "-$(Get-Date -Format dd.MM.yyyy).log"

Start-Transcript -Path $LogLocation -Append -Force

$7ZipPath = "C:\Program Files\7-Zip\7z.exe"

if (-not (Test-Path -Path $7ZipPath -PathType Leaf)) {
    throw "7-Zip is not installed, please install and try running again..."
    exit
}

Set-Location $WorkingDirectory

#Create folder structure in $WorkingDirectory path
if((Test-Path -Path "$($WorkingDirectory)\ISO")-eq $false) {New-Item -Type Directory -Path "$($WorkingDirectory)\ISO" -Force -ErrorAction SilentlyContinue}
if((Test-Path -Path "$($WorkingDirectory)\Mount")-eq $false) {New-Item -Type Directory -Path "$($WorkingDirectory)\Mount" -Force -ErrorAction SilentlyContinue}
if((Test-Path -Path "$($WorkingDirectory)\Final")-eq $false) {New-Item -Type Directory -Path "$($WorkingDirectory)\Final" -Force -ErrorAction SilentlyContinue}
if((Test-Path -Path "$($WorkingDirectory)\Extracted CAB")-eq $false) {New-Item -Type Directory -Path "$($WorkingDirectory)\Extracted CAB" -Force -ErrorAction SilentlyContinue}
if((Test-Path -Path "$($WorkingDirectory)\Extracted EXE")-eq $false) {New-Item -Type Directory -Path "$($WorkingDirectory)\Extracted EXE" -Force -ErrorAction SilentlyContinue}
if((Test-Path -Path "$($WorkingDirectory)\Extracted ISO")-eq $false) {New-Item -Type Directory -Path "$($WorkingDirectory)\Extracted ISO" -Force -ErrorAction SilentlyContinue}
if((Test-Path -Path "$($WorkingDirectory)\CAB")-eq $false) {New-Item -Type Directory -Path "$($WorkingDirectory)\CAB" -Force -ErrorAction SilentlyContinue}
if((Test-Path -Path "$($WorkingDirectory)\Dell Driver EXE")-eq $false) {New-Item -Type Directory -Path "$($WorkingDirectory)\Dell Driver EXE" -Force -ErrorAction SilentlyContinue}

#Expand CAB Folders
Write-Host "INFO:" -ForegroundColor Red -BackgroundColor White
Read-Host -Prompt "Copy .cab files into CAB Folder in ($WorkingDirectory), then press any key to continue"
Invoke-Command {expand.exe -f:* "$($WorkingDirectory)\CAB\*.*" "$($WorkingDirectory)\Extracted CAB"}
Start-Sleep -Seconds 5

#Extract contents from Dell EXE
Write-Host "INFO:" -ForegroundColor Red -BackgroundColor White
Read-Host -Prompt "Copy .exe drivers into Dell Driver EXE folder in ($WorkingDirectory), then press any key to continue"
$EXEPath = "$($WorkingDirectory)\Dell Driver EXE\*.exe"
$EXETarget = "$($WorkingDirectory)\Extracted EXE"
& 'C:\Program Files\7-Zip\7z.exe' x -y $EXEPath "-o$EXETarget"


#Extract ISO Contents
Write-Host "INFO:" -ForegroundColor Red -BackgroundColor White
Read-Host -Prompt "Copy .iso file into ISO Folder in ($WorkingDirectory), then press any key to continue"
$ISOPath = "$($WorkingDirectory)\ISO\*.iso"
$ISOTarget = "$($WorkingDirectory)\Extracted ISO"
Write-Host "Extracting .iso contents to $($WorkingDirectory)\Extracted ISO"
& 'C:\Program Files\7-Zip\7z.exe' x -y $ISOPath "-o$ISOTarget"

#Find Windows Pro Image Index
$ImageIndex = Get-WindowsImage -ImagePath "$($WorkingDirectory)\Extracted ISO\sources\install.wim" | Where-Object {$_.ImageName -eq "Windows 10 Pro"} | Select-Object {$_.ImageIndex} | Out-String
$ImageIndex = $ImageIndex -replace "[^0-9]" , ''
$ImageIndex = $ImageIndex -as [int]

#DISM - Mount Windows Image
Write-Host "Mounting Windows Image..." -ForegroundColor Red -BackgroundColor White
Mount-WindowsImage -ImagePath "$($WorkingDirectory)\Extracted ISO\sources\install.wim" -Index $ImageIndex -Path "$($WorkingDirectory)\Mount"
Write-Host "Image Mounted..." -ForegroundColor Red -BackgroundColor White

#DISM - Add Drivers from Extracted CAB Folder
Write-Host "Adding drivers to mounted image (this will take a while)..." -ForegroundColor Red -BackgroundColor White
Get-ChildItem -Path "$($WorkingDirectory)\Extracted CAB" | ForEach-Object {Add-WindowsDriver -Path "$($WorkingDirectory)\Mount" -Driver $_.FullName -Recurse}
Write-Host "Drivers added" -ForegroundColor Red -BackgroundColor White
Start-Sleep -Seconds 10

#PNPUtil - Add Drivers from Extracted EXE Folder
Write-Host "Adding drivers from Extracted EXE to System32\drivers" -ForegroundColor Red -BackgroundColor White
$ImagePath = "$($WorkingDirectory)\Mount"
$DriverPath = "$($WorkingDirectory)\Extracted EXE"
Invoke-Command {Dism.exe /Image:$ImagePath /Add-Driver /Driver:$DriverPath /Recurse}

#Dismount Image
Dismount-WindowsImage -Path "$($WorkingDirectory)\Mount" -Save
Write-Host "Image dismounted, exporting image to $($WorkingDirectory)\Final" -ForegroundColor Red -BackgroundColor White

#Export Image
$DismInPath = "$($WorkingDirectory)\Extracted ISO\sources\install.wim"
$DismOutPath = "$($WorkingDirectory)\Final\install.esd"
Invoke-Command {Dism.exe /export-image /SourceImageFile:$DismInPath /SourceIndex:$ImageIndex /DestinationImageFile:$DismOutPath /Compress:recovery /CheckIntegrity}
Write-Host "Image exported!" -ForegroundColor Red -BackgroundColor White


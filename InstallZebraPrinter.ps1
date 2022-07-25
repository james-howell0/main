###Re-Runs script in x64 context to utilise PnPUtil###

If ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    Try {
        &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH  
    }
    Catch {
        Throw "Failed to start $PSCOMMANDPATH"
    }
    Exit
}

###Define Log Name and Location###
$LogPath = "$env:ProgramData\HCC\Logs\"
$ScriptName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $Script:MyInvocation.MyCommand -Leaf)))
$LogLocation = $LogPath + $ScriptName + "-Zebra Printer Install-$(Get-Date -Format dd.MM.yyyy).log"

###Define Temp Folder###
$TempFolderLoc = "$env:PROGRAMDATA\HCC\Temp\ZebraPrinter"
$InfTempLoc = "$env:PROGRAMDATA\HCC\Temp\ZebraPrinter\ZBRN.inf"

###Printer Info###
$ZebraPort = "USB001"
$ZebraName = "ZDesigner GK420d"

###Driver Files Loc###
$ZBRNFolder = "$($PSScriptRoot)\ZBRN\*"

###pnputil args###
$INFArgs = @(
    "/add-driver"
    "$InfTempLoc"
)


###Printer Variables###
$portExists = Get-Printerport -Name $ZebraPort -ErrorAction SilentlyContinue
$printDriverExists = Get-PrinterDriver -Name $ZebraName -ErrorAction SilentlyContinue
$GetPrinterExists = Get-Printer -Name "ZDesigner GK420d" -ErrorAction SilentlyContinue

###SCRIPT START###
Start-Transcript -Path $LogLocation -Force

Write-Information "Creating Temp Folder to store driver files in..."
try {
	New-Item -ItemType Directory -Path $TempFolderLoc -Force
	Write-Information "Folder created...."
} catch {
	Write-Error "Failed to create folder..`n"
	Write-Warning "$($_.Exception.Message)`n"
}
	
Write-Information "Copying files to temp folder..."
try {
    Copy-Item -Path  $ZBRNFolder -Destination $TempFolderLoc -Recurse -Force
    Write-Information "Files copied..."
} catch {
    Write-Error "Failed to copy items..`n"
    Write-Warning "$($_.Exception.Message)`n"
}

Write-Information "Beginning Install of Zebra Print Driver`n`nTrying PnPUtil to Stage Driver..."
try {
    Start-Process pnputil.exe -ArgumentList $INFArgs -Wait -PassThru
    Write-Information "Driver added to store"
} catch {
    Write-Error "Failed to stage driver using PnPUtil.exe`n"
    Write-Warning "$($_.Exception.Message)`n"
}

Write-Information "Fetching driver from driver store - Storing output in ZebraINF Variable"
try {
    Get-WindowsDriver -All -Online | Where-Object {$_.OriginalFileName -like '*zbrn.inf'} | Select-Object -ExpandProperty OriginalFileName -OutVariable ZebraINF
    Write-Information "Output stored in ZebraINF Variable"
} catch {
    Write-Error "Failed to fetch driver from Driver Store...`n"
    Write-Warning "$($_.Exception.Message)`n"
}

Write-Information "Creating Printer port with name USB001"
if(-not $portExists){
    try {
        Add-PrinterPort -Name $ZebraPort -ErrorAction SilentlyContinue
        Write-Information "Printer port created"
    } catch {
        Write-Error "Failed to create printer port...`n"
        Write-Warning "$($_.Exception.Message)`n"
    }
}

Write-Information "Adding printer driver ZDesigner GK420d"
if(-not $printDriverExists){
    try {
        Add-PrinterDriver -Name "ZDesigner GK420d" -InfPath $ZebraINF
        Write-Information "Printer driver added"
    } catch {
        Write-Error "Failed to add printer driver...`n"
        Write-Warning "$($_.Exception.Message)`n"
    } 
}

Write-Information "Adding printer with name ZDesigner GK420d"
if(-not $GetPrinterExists){
    try {
        Add-Printer -Name "ZDesigner GK420d" -PortName $ZebraPort -DriverName $ZebraName
        Write-Information "Printer added"
    } catch {
        Write-Error "Failed to add printer...`n"
        Write-Warning "$($_.Exception.Message)`n"
    }
}

###Set Loc outside of temp folder so files can be removed###
Set-Location -Path "$env:PROGRAMDATA\HCC\"

Write-Information "Removing Temp Files..."
try {
    Remove-Item -Path $TempFolderLoc -Recurse -Force
    Write-Information "Files Removed"
} catch {
    Write-Error "Failed to remove temp files`n"
    Write-Warning "$($_.Exception.Message)`n"
}

Stop-Transcript
###SCRIPT END###

exit
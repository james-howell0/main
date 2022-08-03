while ($true){
    Get-ChildItem -Path "C:\Windows\IMECache\" | ForEach-Object {
        if (([System.IO.FileInfo]$_.FullName).LastWriteTime.Date -ge [datetime]::Today ){
            $folderName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path -Path $_.FullName -Leaf)))
            break
        }    
    }
}
$outputFolder = "$env:ProgramData\HCC\Temp\$folderName"
if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder -Force 
}
while ($true){
    Get-ChildItem -Path "C:\Windows\IMECache\" | ForEach-Object {
        if (([System.IO.FileInfo]$_.FullName).LastWriteTime.Date -ge [datetime]::Today ){     
            Get-ChildItem -Path $_.FullName | ForEach-Object {Copy-Item -Path $_.FullName -Destination $outputFolder -Recurse -Force -ErrorAction SilentlyContinue}
            Write-Host "Copying Files..." -ForegroundColor Green -BackgroundColor White
        }
    }
}

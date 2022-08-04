Stop-Service -Name "Windows Update" -Force
if (Test-Path -Path "C:\Windows\SoftwareDistribution.old") {
    Remove-Item -Path "C:\Windows\SoftwareDistribution.old" -Force
    Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "C:\Windows\SoftwareDistribution.old" -Force -ErrorAction SilentlyContinue
} else {
    Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "C:\Windows\SoftwareDistribution.old" -Force -ErrorAction SilentlyContinue
}
Start-Service -Name "Windows Update"
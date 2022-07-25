New-Item -ItemType Directory -Path "C:\ProgramData\HCC\Temp\PerformanceMonitor" -Force
$SourceFolder = "C:\ProgramData\HCC\Temp\PerformanceMonitor"
$MemoryUsageCsv = "C:\ProgramData\HCC\Temp\PerformanceMonitor\MemoryUsage.csv"
$MemoryApps = "C:\ProgramData\HCC\Temp\PerformanceMonitor\MemoryApps.csv"
$scriptpath = "$($PSScriptRoot)\FetchDiskUsageBLG.ps1"
Set-Content -Path $MemoryUsageCsv -Value ""
Set-Content -Path $MemoryApps -Value ""


Start-Process "Powershell.exe" -ArgumentList "& '$scriptpath'" -WindowStyle Hidden -Verb runas

function Get-Memory {
 # Get Computer Object
 $CompObject =  Get-WmiObject -Class WIN32_OperatingSystem
 $Memory = ((($CompObject.TotalVisibleMemorySize - $CompObject.FreePhysicalMemory)*100)/ $CompObject.TotalVisibleMemorySize)
 
 Write-Output "Memory Usage (%) at $((Get-Date).ToString('T')): " $Memory | Add-Content -Path $MemoryUsageCsv -Force
}
function Get-MemoryApps {
     # Top 5 process Memory Usage (MB)
    $processMemoryUsage = Get-WmiObject WIN32_PROCESS | Sort-Object -Property ws -Descending | Select-Object -first 5 processname
    Write-Output "Applications Utilising most Resource at $((Get-Date).ToString('T')): " $processMemoryUsage | Add-Content -Path $MemoryApps -Force
}

$timer = new-timespan -Minutes 5
$clock = [diagnostics.stopwatch]::StartNew()
while ($clock.elapsed -lt $timer){
Get-Memory
Get-MemoryApps
Start-Sleep -seconds 30
}

$ZipDest = ($SourceFolder+"\$($env:COMPUTERNAME)-PerformanceScript.zip")
Compress-Archive -Path $SourceFolder -DestinationPath $ZipDest

Start-Sleep -Seconds 5

$MailMessage= @{
    To="james.howell2@hants.gov.uk"
    From="james.howell2@hants.gov.uk"
    Subject="Performance Monitor results for: $env:COMPUTERNAME"
    Body="
    
    <h1>Script has run on $env:COMPUTERNAME</h1>
    "
    SmtpServer="mailrelay.hants.gov.uk"
}
Send-MailMessage @MailMessage -BodyAsHtml -Attachments $ZipDest
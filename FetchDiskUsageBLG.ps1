$CounterBlg = "C:\ProgramData\HCC\Temp\PerformanceMonitor\CounterBLG.blg"
function Get-Counters {
    $counters = @(
        "\PhysicalDisk(0 C:)\Avg. Disk sec/Read",
        "\PhysicalDisk(0 C:)\Avg. Disk sec/Write",
        "\PhysicalDisk(0 C:)\% Disk Read",
        "\PhysicalDisk(0 C:)\% Disk Write",
        “\Memory\Available Bytes”,
        "\Process(*)\% Processor Time"
    )
    Get-Counter -Counter $counters -SampleInterval 30 -MaxSamples 10 -ErrorAction SilentlyContinue | Export-Counter -Path $CounterBlg -Force
}

Get-Counters
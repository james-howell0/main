param (
    [Parameter(Mandatory=$true)]
    [string]
    $DeviceName
)

$escChar = [regex]::Escape($DeviceName)

Get-PnPDevice | Where-Object {$_.InstanceId -Match $escChar} | Format-Table -Property "FriendlyName","InstanceId"
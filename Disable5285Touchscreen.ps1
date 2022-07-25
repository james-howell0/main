$PnPDeviceTouchscreen = Get-PnPDevice -FriendlyName "HID-Compliant Touch Screen"

if ($PnPDeviceTouchscreen) {
    Get-PnPDevice -FriendlyName "HID-Compliant Touch Screen" | Disable-PnPDevice -Confirm:$false -ErrorAction SilentlyContinue
} else {
    exit
}
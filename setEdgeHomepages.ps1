$checkPath = Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\RestoreOnStartupURLs"


if (!($checkPath)) {
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "RestoreOnStartupURLs"
Get-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\RestoreOnStartupURLs" | New-ItemProperty -PropertyType String -Name 1 -Value "https://login.microsoftonline.com/login.srf?wa=wsignin1%2E0&rver=6%2E1%2E6206%2E0&wreply=https%3A%2F%2Fhants.sharepoint.com%2Fsites%2Fcn&whr=hants.gov.uk"
Get-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\RestoreOnStartupURLs" | New-ItemProperty -PropertyType String -Name 2 -Value "https://hub.hiow.gov.uk"
} else {
    exit
}
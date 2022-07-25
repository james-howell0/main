#Query to check current Language set - Value 1 will be the current language that is set.
$regquery = (Get-ItemProperty -Path "HKCU:\Keyboard Layout\Preload" -Name 1).1

if ($regquery -notmatch "00000809") {
    Set-WinUserLanguageList -LanguageList "en-GB" -Force
} else {
    Write-Output "Language already set to UK"
}

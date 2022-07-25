function Get-Key {
    param (
        [string]$ParentKey,
        [string]$KeyName
    ) 
    #===============================================================================
    # Purpose: 			To create a regkey and all parent keys
    # Assumptions:		
    # Effects:	
    # Inputs:
    #  $ParentKey:		The Root key (e.g. HKLM, HKCU)
    #  $KeyName:        The key to be set
    # Calls:
    # Returns:
    #
    # Notes:			Writes to console if -Verbose switch is used on script
    #===============================================================================
    Write-Verbose "ParentKey: $($ParentKey)"
    Write-Verbose "Key to set: $($KeyName)"
    for ($i = 0; $i -lt $KeyName.Split("\").Count; $i++) {
        try {
            $logkey = ($KeyName.split("\")[0..$i] -join "\")
            Write-Verbose "Trying path: $($ParentKey)\$($logkey)" 
            $Key = get-item -Path ("{0}:\{1}" -f $ParentKey, ($KeyName.split("\")[0..$i] -join "\")) -ErrorAction Stop
            Write-Verbose "Key = $($Key)"
        }
        catch {
            Write-Information "The error above is expected - Creating the key that failed"
            $logkey = ($KeyName.split("\")[0..$i] -join "\")
            Write-Verbose "Creating path: $($ParentKey)\$($logkey)" 
            $Key = new-item -Path ("{0}:\{1}" -f $ParentKey, ($KeyName.split("\")[0..$i] -join "\"))
            Write-Verbose "Key = $($Key)"
        }
    }
    return $Key
}

#Define Variables for script
$Reg64 = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Microsoft\Office\16.0\Outlook\SchedulingInformation\FreeBusySupport"
$Reg32 = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Wow6432Node\Microsoft\Office\16.0\Outlook\SchedulingInformation\FreeBusySupport"

##Script Start

#Add keys in x64 Registry path
if ($(Test-Path -Path $Reg64) -ne $true) {
    Write-Information "Key in x64 Registry does not exist, adding...."
    Get-Key -ParentKey HKLM -KeyName "\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Microsoft\Office\16.0\Outlook\SchedulingInformation\FreeBusySupport" | Set-ItemProperty -Name "EX" -Value "{0006F014-0000-0000-C000-000000000046}" -Force
    Get-Key -ParentKey HKLM -KeyName "\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Microsoft\Office\16.0\Outlook\SchedulingInformation\FreeBusySupport" | Set-ItemProperty -Name "SMTP" -Value "{0006F049-0000-0000-C000-000000000046}" -Force
} else {
    Write-Information "Key already exists"
}

#Add keys in x86 Registry path
if ($(Test-Path -Path $Reg32) -ne $true) {
    Write-Information "Key in x86 Registry does not exist, adding...."
    Get-Key -ParentKey HKLM -KeyName "\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Wow6432Node\Microsoft\Office\16.0\Outlook\SchedulingInformation\FreeBusySupport" | Set-ItemProperty -Name "EX" -Value "{0006F014-0000-0000-C000-000000000046}" -Force
    Get-Key -ParentKey HKLM -KeyName "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Wow6432Node\Microsoft\Office\16.0\Outlook\SchedulingInformation\FreeBusySupport" | Set-ItemProperty -Name "SMTP" -Value "{0006F049-0000-0000-C000-000000000046}" -Force
} else {
    Write-Information "Key already exists"
}

##Script End
exit
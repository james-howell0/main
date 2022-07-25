$ScriptLoc = "C:\Program Files\WindowsPowerShell\Scripts"
$ConfirmPreference = 'None'
$AttachmentName = $ScriptLoc + "\$env:COMPUTERNAME-Hash.csv"

function Email-Send {
    Param()
        $MailMessage= @{
            To="desktop.support.team@hants.gov.uk"
            From="desktop.support.team@hants.gov.uk"
            Subject="Windows Autopilot Hash for: $env:COMPUTERNAME"
            Body="
            
            <h1>Script has run on $env:COMPUTERNAME</h1>
            "
            SmtpServer="mailrelay.hants.gov.uk"
        }
        Send-MailMessage @MailMessage -BodyAsHtml -Attachments $AttachmentName -ErrorAction SilentlyContinue
    }
    Email-Send


Install-Script -Name Get-WindowsAutopilotInfo -ErrorAction SilentlyContinue -Confirm:$false -Force
Set-Location $ScriptLoc
Invoke-Expression ".\Get-WindowsAutoPilotInfo.ps1 -OutputFile .\$env:COMPUTERNAME-Hash.csv"
Start-Sleep -Seconds 10
Email-Send


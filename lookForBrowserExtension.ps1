
$checkExtPath = Get-ChildItem -Path "C:\Users\*\AppData\Local\Microsoft\Edge\User Data\Default\Extensions\hhibffcmhnkpmdadmpmbeankopeegecp"

function Email-Send {
    Param()
        $MailMessage= @{
            To="desktop.support.team@hants.gov.uk"
            From="desktop.support.team@hants.gov.uk"
            Subject="High Contrast Extension has been found on: $env:COMPUTERNAME"
            Body="
            
            <h1>Script has run on $env:COMPUTERNAME</h1>

            <p>Filepath: <br> $checkExtPath</p>
            "
            SmtpServer="mailrelay.hants.gov.uk"
        }
        Send-MailMessage @MailMessage -BodyAsHtml -ErrorAction SilentlyContinue
    }

if ($checkExtPath) {
    #Send email to Desktop Support mailbox if extension filepath exists
    Email-Send
} else {
    #Exit if Extension filepath does not exist
    exit
}

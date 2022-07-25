$DeviceList = "PORT-BT2SYM2", "PORT-9GBSYM2", "PORT-213SYM2", "PORT-BDFXJM2", "PORT-6HWSYM2", "PORT-32YKPW2", "PORT-65R66M2", "PORT-GHXRYM2", "PORT-FHCTJM2", "PORT-59DQYM2", "PORT-5QXSJM2", "POOL-CW1GVP2", "PORT-52DQYM2", "PORT-CMD99Y2", "PORT-78RRYM2", "PORT-7V2QYM2", "PORT-7CHPYM2", "PORT-C1XSYM2", "PORT-H9LRYM2", "PORT-HFVQYM2", "PORT-9FLRYM2", "PORT-JPVQYM2", "PORT-HJCTJM2"

$properties = @('ObjectId')
$exportpath = "C:\ProgramData\HCC\ObjectID.csv"
Connect-AzureAD
foreach ($devices in $DeviceList) {
	Get-AzureADDevice -SearchString $devices | Select-Object $properties
}
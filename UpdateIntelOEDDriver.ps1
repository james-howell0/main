
$queryTable = Get-WMIObject -Class Win32_PnpEntity | Where-Object {$_.Caption -match "OED" -and $_.Status -match "Error"} | Format-Table $queryTableResultFormat -AutoSize
$queryTableResultFormat = @{Expression = {$_.Name}; Label = "DeviceName"}, @{Expression = {$_.ConfigManagerErrorCode} ; Label = "StatusCode" }, @{Expression = {$_.Status} ; Label = "Status" }


function Get-oedOEM{
    $oedName = "Intel(R) Smart Sound Technology (Intel(R) SST) OED"
    $oedQueryTableResultFormat = @{Expression = {$_.InfName}; Label = "InfName"}
    $oedQuery = Get-CimInstance -Class Win32_PnpSignedDriver | Where-Object {$_.DeviceName -like $oedName} | Format-Table $oedQueryTableResultFormat -AutoSize
    $oedQuery
}
function Get-AudioOEM{
    $audioControllerName = "Intel(R) Smart Sound Technology (Intel(R) SST) Audio Controller"
    $audioContQueryTableResultFormat = @{Expression = {$_.InfName}; Label = "InfName"}
    $audioContQuery = Get-CimInstance -Class Win32_PnpSignedDriver | Where-Object {$_.DeviceName -like $audioControllerName} | Format-Table $audioContQueryTableResultFormat -AutoSize
    $audioContQuery
}

###pnputil args###
$INFArgs = @(
    "/delete-driver"
    "$InfTempLoc"
)

function Check-DellModel {
    $checkModel = Get-ComputerInfo -Property "CsModel"
    if ($checkModel -match "Latitude 5300" -or $checkModel -match "Latitude 7200" -or $checkModel -match "Latitude 7210") {
        return $true
        Write-Output "Model is in list"
    } else {
        return $false
        Write-Output "model is not in list"
    }
}

Get-AudioOEM

<# if ($(Check-DellModel -eq $true)) {
    if ($queryTable | Select-Object {$_.StatusCode -match "Error" -and $_.Caption -match "OED"}) {
        Write-Output "Status code is Error"
        #Update Driver using pnputil
    } else {
        Write-Output "Status code is not error or driver does no exist"
    }
} elseif ($(Check-DellModel -eq $false)) {
    exit
} #>
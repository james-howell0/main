[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $user
)

$getUser = Get-User $user | Select-Object -ExpandProperty DistinguishedName

Get-Recipient -Filter "Members -eq '$getUser'" | Select-Object Name
$DistList=(
    "DL_Commercial - Fee Earners Gateway House",
    "DL_Commercial - Fee Earners Guildford",
    "DL_Commercial - Fee Earners London City",
    "DL_Commercial - Fee Earners Lymington",
    "DL_Commercial - Fee Earners Richmond 2TG",
    "DL_Commercial - Fee Earners Richmond 9TG",
    "DL_Commercial - Fee Earners Woking"
)

foreach ($object in $DistList) {

    try {
        Get-DistributionGroup -Identity $object | Format-Table -Property Name
        Get-DistributionGroupMember -Identity $object | Format-Table -Property Name
    } catch {}
}
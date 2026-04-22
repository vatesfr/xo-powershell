# SPDX-License-Identifier: Apache-2.0

$script:XO_VM_SNAPSHOT_FIELDS = "uuid,name_label,name_description,snapshot_time,snapshot_of,power_state,tags,CPUs,memory"

function ConvertTo-XoVmSnapshotObject
{
    <#
    .SYNOPSIS
        Convert a VM snapshot object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a VM snapshot object from the API to a PowerShell object with proper properties.
    .PARAMETER InputObject
        The VM snapshot object from the API.
    .EXAMPLE
        ConvertTo-XoVmSnapshotObject -InputObject $object
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [PSObject] $InputObject
    )

    # Create object with direct properties from API
    $snapshotObj = [PSCustomObject]@{
        PSTypeName     = "XoPowershell.VmSnapshot"
        VmSnapshotUuid = $InputObject.uuid
        Name           = $InputObject.name_label
        Description    = $InputObject.name_description
        PowerState     = $InputObject.power_state
        SnapshotOf     = $InputObject.snapshot_of
        SnapshotTime   = [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.snapshot_time).ToLocalTime()
        Memory         = $InputObject.memory
    }

    if ($null -ne $InputObject.CPUs)
    {
        if ($InputObject.CPUs.PSObject.Properties.Name -contains 'number')
        {
            $snapshotObj | Add-Member -MemberType NoteProperty -Name CPUs -Value $InputObject.CPUs.number
        }
        elseif ($InputObject.CPUs.PSObject.Properties.Name -contains 'max')
        {
            $snapshotObj | Add-Member -MemberType NoteProperty -Name CPUs -Value $InputObject.CPUs.max
        }
    }

    return $snapshotObj
}

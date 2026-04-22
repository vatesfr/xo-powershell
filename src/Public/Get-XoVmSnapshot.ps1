# SPDX-License-Identifier: Apache-2.0

function Get-XoVmSnapshot
{
    <#
    .SYNOPSIS
        Get VM snapshots.
    .DESCRIPTION
        Retrieves VM snapshots from Xen Orchestra. Can retrieve specific snapshots by their UUID
        or filter snapshots by various criteria.
    .PARAMETER VmSnapshotUuid
        The UUID(s) of the VM snapshot(s) to retrieve.
    .PARAMETER Filter
        Filter to apply to the snapshot query.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoVmSnapshot
        Returns up to 25 VM snapshots.
    .EXAMPLE
        Get-XoVmSnapshot -Limit 0
        Returns all VM snapshots without limit.
    .EXAMPLE
        Get-XoVmSnapshot -VmSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the VM snapshot with the specified UUID.
    .EXAMPLE
        Get-XoVmSnapshot -Filter "name_label:backup"
        Returns VM snapshots with "backup" in their name (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.VmSnapshot")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VmSnapshotUuid")]
        [ValidateNotNullOrEmpty()]
        [Alias("Snapshot")]
        [string[]]$VmSnapshotUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $params = @{ fields = $script:XO_VM_SNAPSHOT_FIELDS }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "VmSnapshotUuid")
        {
            foreach ($id in $VmSnapshotUuid)
            {
                try
                {
                    Write-Verbose "Getting VM snapshot with UUID $id"
                    $snapshotData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vm-snapshots/$id" @script:XoRestParameters
                    ConvertTo-XoVmSnapshotObject $snapshotData
                }
                catch
                {
                    throw ("Failed to retrieve VM snapshot with UUID {0}: {1}" -f $id, $_)
                }
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter)
            {
                $params["filter"] = $Filter
            }

            if ($Limit)
            {
                $params["limit"] = $Limit
            }

            try
            {
                $uri = "$script:XoHost/rest/v0/vm-snapshots"
                Write-Verbose "Getting VM snapshots from $uri with parameters: $($params | ConvertTo-Json -Compress)"

                $snapshotsResponse = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if (!$snapshotsResponse -or $snapshotsResponse.Count -eq 0)
                {
                    Write-Verbose "No VM snapshots found matching criteria"
                    return
                }

                Write-Verbose "Found $($snapshotsResponse.Count) VM snapshots"

                foreach ($snapshotItem in $snapshotsResponse)
                {
                    ConvertTo-XoVmSnapshotObject $snapshotItem
                }
            }
            catch
            {
                throw ("Failed to list VM snapshots. Error: {0}" -f $_)
            }
        }
    }
}

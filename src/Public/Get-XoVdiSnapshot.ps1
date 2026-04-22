# SPDX-License-Identifier: Apache-2.0

function Get-XoVdiSnapshot
{
    <#
    .SYNOPSIS
        Get VDI snapshots from Xen Orchestra.
    .DESCRIPTION
        Retrieves VDI snapshots from Xen Orchestra. Can retrieve specific snapshots by their UUID
        or filter snapshots by various criteria.
    .PARAMETER VdiSnapshotUuid
        The UUID(s) of the VDI snapshot(s) to retrieve.
    .PARAMETER Filter
        Filter to apply to the snapshot query.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoVdiSnapshot
        Returns up to 25 VDI snapshots.
    .EXAMPLE
        Get-XoVdiSnapshot -Limit 0
        Returns all VDI snapshots without limit.
    .EXAMPLE
        Get-XoVdiSnapshot -VdiSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the VDI snapshot with the specified UUID.
    .EXAMPLE
        Get-XoVdiSnapshot -Filter "name_label:backup*"
        Returns VDI snapshots with names starting with "backup" (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VdiSnapshotUuid")]
        [Alias("VdiSnapshotId")]
        [string[]]$VdiSnapshotUuid,

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

        $params = @{ fields = $script:XO_VDI_SNAPSHOT_FIELDS }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "VdiSnapshotUuid")
        {
            foreach ($id in $VdiSnapshotUuid)
            {
                Get-XoSingleVdiSnapshotById -VdiSnapshotUuid $id -Params $params
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter)
            {
                $params['filter'] = $Filter
            }

            if ($Limit)
            {
                $params['limit'] = $Limit
            }

            try
            {
                Write-Verbose "Getting VDI snapshots with parameters: $($params | ConvertTo-Json -Compress)"
                $uri = "$script:XoHost/rest/v0/vdi-snapshots"
                $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if (!$response -or $response.Count -eq 0)
                {
                    Write-Verbose "No VDI snapshots found matching criteria"
                    return
                }

                Write-Verbose "Found $($response.Count) VDI snapshots"

                foreach ($snapshotItem in $response)
                {
                    ConvertTo-XoVdiSnapshotObject -InputObject $snapshotItem
                }
            }
            catch
            {
                throw ("Failed to list VDI snapshots. Error: {0}" -f $_)
            }
        }
    }
}

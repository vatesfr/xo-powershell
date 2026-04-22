# SPDX-License-Identifier: Apache-2.0

function Remove-XoVmStatDataSource
{
    <#
    .SYNOPSIS
        Remove a stats data source on a VM.
    .DESCRIPTION
        Calls DELETE /vms/{id}/stats/data_source/{data_source} to remove stat data source.
    .PARAMETER VmUuid
        The UUID of the target VM.
    .PARAMETER DataSource
        The name of the stats data source (e.g. 'cpu0', 'memory').
    .EXAMPLE
        Remove-XoVmStatDataSource -VmUuid "<vm>" -DataSource "cpu0"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$VmUuid,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$DataSource
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }
    }

    process
    {
        if (-not $PSCmdlet.ShouldProcess("VM $VmUuid", "remove stat data source '$DataSource'"))
        {
            return
        }

        $uri = "$script:XoHost/rest/v0/vms/$VmUuid/stats/data_source/$DataSource"
        Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
    }
}

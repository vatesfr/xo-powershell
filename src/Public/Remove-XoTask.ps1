# SPDX-License-Identifier: Apache-2.0

function Remove-XoTask
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra tasks.
    .DESCRIPTION
        Issues DELETE /tasks/{id}. Accepts multiple IDs and pipeline input by property name.
    .PARAMETER TaskId
        The ID(s) of the task(s) to delete.
    .EXAMPLE
        Remove-XoTask -TaskId "<id>"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$TaskId
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
        foreach ($id in $TaskId)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete task"))
            {
                $uri = "$script:XoHost/rest/v0/tasks/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

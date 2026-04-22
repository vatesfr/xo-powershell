# SPDX-License-Identifier: Apache-2.0

function Stop-XoTask
{
    <#
    .SYNOPSIS
        Abort one or more running Xen Orchestra tasks.
    .DESCRIPTION
        POSTs to /tasks/{id}/actions/abort to request cancellation of the specified task. Some XAPI tasks cannot be aborted; those will return an error. Aborting a task can leave partial state behind (e.g. a half-migrated VM) - use with care.
    .PARAMETER TaskId
        The ID(s) of the task(s) to abort. Accepts pipeline input by property name.
    .EXAMPLE
        Stop-XoTask -TaskId "0m8k2zkzi"
    .EXAMPLE
        Get-XoTask -Status pending | Stop-XoTask
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
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
            if ($PSCmdlet.ShouldProcess($id, "abort"))
            {
                $uri = "$script:XoHost/rest/v0/tasks/$id/actions/abort"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters
            }
        }
    }
}


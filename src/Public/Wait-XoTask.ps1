# SPDX-License-Identifier: Apache-2.0

function Wait-XoTask
{
    <#
    .SYNOPSIS
        Wait for task completion.
    .DESCRIPTION
        Waits for the specified tasks to complete and optionally returns the result.
    .PARAMETER TaskId
        The ID(s) of the task(s) to wait for.
    .PARAMETER PassThru
        If specified, returns the task objects after completion.
    .EXAMPLE
        Wait-XoTask -TaskId "0m8k2zkzi"
        Waits for the task to complete.
    .EXAMPLE
        Wait-XoTask -TaskId "0m8k2zkzi" -PassThru
        Waits for the task to complete and returns the task object.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$TaskId,

        [Parameter()]
        [switch]$PassThru
    )

    begin
    {
        $params = @{
            fields = $script:XO_TASK_FIELDS
            wait   = "result"
        }
        $ids = @()
    }

    process
    {
        $ids += $TaskId
    }

    end
    {
        foreach ($id in $ids)
        {
            try
            {
                $uri = "$script:XoHost/rest/v0/tasks/$id"
                $result = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if ($PassThru -and $result)
                {
                    ConvertTo-XoTaskObject -InputObject $result
                }
            }
            catch
            {
                throw ("Error waiting for task {0}: {1}" -f $id, $_)
            }
        }
    }
}

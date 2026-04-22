# SPDX-License-Identifier: Apache-2.0

function Get-XoTask
{
    <#
    .SYNOPSIS
        Get tasks from Xen Orchestra.
    .DESCRIPTION
        Retrieves tasks from Xen Orchestra. Can retrieve specific tasks by their ID
        or filter tasks by status.
    .PARAMETER TaskId
        The ID(s) of the task(s) to retrieve.
    .PARAMETER Status
        Filter tasks by status. Valid values: pending, success, failure.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoTask
        Returns up to 25 tasks of any status.
    .EXAMPLE
        Get-XoTask -Status failure
        Returns failed tasks.
    .EXAMPLE
        Get-XoTask -TaskId "0m8k2zkzi"
        Returns the task with the specified ID.
    .EXAMPLE
        Get-XoTask -Limit 5
        Returns the first 5 tasks.
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "TaskId")]
        [ValidateNotNullOrEmpty()]
        [string[]]$TaskId,

        [Parameter(ParameterSetName = "Filter")]
        [ValidateSet("pending", "success", "failure")]
        [string]$Status,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $params = @{
            fields = $script:XO_TASK_FIELDS
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "TaskId")
        {
            foreach ($id in $TaskId)
            {
                Get-XoSingleTaskById -TaskId $id -Params $params
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Status)
            {
                $params['filter'] = $Status
            }

            if ($Limit)
            {
                $params['limit'] = $Limit
            }

            try
            {
                Write-Verbose "Getting tasks with parameters: $($params | ConvertTo-Json -Compress)"
                $uri = "$script:XoHost/rest/v0/tasks"
                $tasksResponse = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if ($null -eq $tasksResponse -or $tasksResponse.Count -eq 0)
                {
                    Write-Verbose "No tasks found matching criteria"
                    return
                }

                Write-Verbose "Found $($tasksResponse.Count) tasks"

                foreach ($taskItem in $tasksResponse)
                {
                    ConvertTo-XoTaskObject -InputObject $taskItem
                }
            }
            catch
            {
                if ($PSBoundParameters.ContainsKey('Status'))
                {
                    throw ("Failed to retrieve tasks with status {0}: {1}" -f $Status, $_)
                }
                else
                {
                    throw ("Failed to retrieve tasks: {0}" -f $_)
                }
            }
        }
    }
}

New-Alias -Name Get-XoTaskDetails -Value Get-XoTask

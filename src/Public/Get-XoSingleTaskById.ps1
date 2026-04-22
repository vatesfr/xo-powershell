# SPDX-License-Identifier: Apache-2.0

function Get-XoSingleTaskById
{
    <#
    .SYNOPSIS
        Get a single task by ID
    .DESCRIPTION
        Retrieves a single task from the API by its ID
    .PARAMETER TaskId
        The ID of the task to retrieve
    .PARAMETER Params
        Additional parameters to pass to the API
    .EXAMPLE
        Get-XoSingleTaskById -TaskId "0m8k2zkzi"
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
    param (
        [string]$TaskId,
        [hashtable]$Params
    )
    process
    {

        try
        {
            Write-Verbose "Getting task with ID $TaskId"
            $uri = "$script:XoHost/rest/v0/tasks/$TaskId"
            $taskData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $Params

            if ($taskData)
            {
                return ConvertTo-XoTaskObject -InputObject $taskData
            }
        }
        catch
        {
            throw ("Failed to retrieve task with ID {0}: {1}" -f $TaskId, $_)
        }
        return $null
    }
}

# SPDX-License-Identifier: Apache-2.0

$script:XO_TASK_FIELDS = "id,properties,start,status,result,updatedAt,end,progress"

function ConvertTo-XoTaskObject
{
    <#
    .SYNOPSIS
        Convert a task object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a task object from the API to a PowerShell object with proper properties.
    .PARAMETER InputObject
        The task object from the API.
    .EXAMPLE
        ConvertTo-XoTaskObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        $InputObject
    )

    process
    {
        $name = if ($InputObject.properties.name)
        {
            $InputObject.properties.name
        }
        elseif ($InputObject.properties.method)
        {
            $InputObject.properties.method
        }
        else
        {
            "Unknown"
        }

        $type = if ($InputObject.properties.type)
        {
            $InputObject.properties.type
        }
        else
        {
            ""
        }

        $startTime = if ($InputObject.start -and $InputObject.start -gt 0)
        {
            [System.DateTimeOffset]::FromUnixTimeMilliseconds($InputObject.start).ToLocalTime()
        }
        else
        {
            $null
        }

        $endTime = if ($InputObject.end -and $InputObject.end -gt 0)
        {
            [System.DateTimeOffset]::FromUnixTimeMilliseconds($InputObject.end).ToLocalTime()
        }
        else
        {
            $null
        }

        $message = if ($InputObject.result.message)
        {
            $InputObject.result.message
        }
        elseif ($InputObject.result.code)
        {
            $InputObject.result.code
        }
        else
        {
            ""
        }

        $props = @{
            PSTypeName = "XoPowershell.Task"
            TaskId     = $InputObject.id
            Name       = $name
            Type       = $type
            Status     = $InputObject.status
            Progress   = if ($null -ne $InputObject.progress)
            {
                $InputObject.progress
            }
            else
            {
                0
            }
            StartTime  = $startTime
            EndTime    = $endTime
            Message    = $message
        }

        [PSCustomObject]$props
    }
}

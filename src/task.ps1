# SPDX-License-Identifier: Apache-2.0

$script:XO_TASK_FIELDS = "id,properties,start,status,result,updatedAt,end,progress"

function ConvertTo-XoTaskObject {
    <#
    .SYNOPSIS
        Convert a task object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a task object from the API to a PowerShell object with proper properties.
    .PARAMETER InputObject
        The task object from the API.
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        $InputObject
    )

    process {
        # Extract and format the name from either properties.name or properties.method
        $name = if ($InputObject.properties.name) { 
            $InputObject.properties.name 
        } elseif ($InputObject.properties.method) { 
            $InputObject.properties.method 
        } else { 
            "Unknown" 
        }

        # Extract task type if available
        $type = if ($InputObject.properties.type) { $InputObject.properties.type } else { "" }

        # Convert timestamps to DateTime if they exist
        $startTime = if ($InputObject.start -and $InputObject.start -gt 0) { 
            [System.DateTimeOffset]::FromUnixTimeMilliseconds($InputObject.start).ToLocalTime() 
        } else { 
            $null 
        }
        
        $endTime = if ($InputObject.end -and $InputObject.end -gt 0) { 
            [System.DateTimeOffset]::FromUnixTimeMilliseconds($InputObject.end).ToLocalTime() 
        } else { 
            $null 
        }
        
        # Build the message from result if available
        $message = if ($InputObject.result.message) { 
            $InputObject.result.message 
        } elseif ($InputObject.result.code) {
            $InputObject.result.code
        } else { 
            "" 
        }

        # Create and return the task object
        $props = @{
            PSTypeName = "XoPowershell.Task"
            TaskId     = $InputObject.id
            Name       = $name
            Type       = $type
            Status     = $InputObject.status
            Progress   = if ($null -ne $InputObject.progress) { $InputObject.progress } else { 0 }
            StartTime  = $startTime
            EndTime    = $endTime
            Message    = $message
        }
        
        [PSCustomObject]$props
    }
}

function ConvertFrom-XoTaskHref {
    <#
    .SYNOPSIS
        Convert a task URL to a task object
    .DESCRIPTION
        Extracts the task ID from a URL and retrieves the task from the API
    .PARAMETER Uri
        The task URL to convert
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string]$Uri
    )

    process {
        if ($Uri -notmatch "\/rest\/v0\/tasks\/([0-9a-z]+)") {
            throw "Bad task href format: $Uri"
        }
        
        $taskId = $matches[1]
        Get-XoTask -TaskId $taskId
    }
}

function Get-XoSingleTaskById {
    <#
    .SYNOPSIS
        Get a single task by ID
    .DESCRIPTION
        Retrieves a single task from the API by its ID
    .PARAMETER TaskId
        The ID of the task to retrieve
    .PARAMETER Params
        Additional parameters to pass to the API
    #>
    [CmdletBinding()]
    param (
        [string]$TaskId,
        [hashtable]$Params
    )
    
    try {
        Write-Verbose "Getting task with ID $TaskId"
        $uri = "$script:XoHost/rest/v0/tasks/$TaskId"
        $taskData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $Params
        
        if ($taskData) {
            return ConvertTo-XoTaskObject -InputObject $taskData
        }
    } catch {
        throw ("Failed to retrieve task with ID {0}: {1}" -f $TaskId, $_)
    }
    return $null
}

function Get-XoTask {
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
        Returns up to 25 pending tasks.
    .EXAMPLE
        Get-XoTask -Status failure
        Returns failed tasks.
    .EXAMPLE
        Get-XoTask -TaskId "0m8k2zkzi"
        Returns the task with the specified ID.
    .EXAMPLE
        Get-XoTask -Limit 5
        Returns the first 5 pending tasks.
    #>
    [CmdletBinding(DefaultParameterSetName = "Status")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "TaskId")]
        [ValidateNotNullOrEmpty()]
        [string[]]$TaskId,

        [Parameter(ParameterSetName = "Status")]
        [ValidateSet("pending", "success", "failure")]
        [string]$Status = "pending",
        
        [Parameter(ParameterSetName = "Status")]
        [int]$Limit = $(if ($null -ne $script:XO_DEFAULT_LIMIT) { $script:XO_DEFAULT_LIMIT } else { 25 })
    )

    if (-not $script:XoHost -or -not $script:XoRestParameters) {
        throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
    }
    
    $params = @{
        fields = $script:XO_TASK_FIELDS
    }

    if ($PSCmdlet.ParameterSetName -eq "TaskId") {
        foreach ($id in $TaskId) {
            Get-XoSingleTaskById -TaskId $id -Params $params
        }
        return
    }

    try {
        $params['filter'] = $Status
        
        if ($Limit -ne 0) {
            $params['limit'] = $Limit
            if (!$PSBoundParameters.ContainsKey('Limit')) {
                Write-Warning "No limit specified. Using default limit of $Limit. Use -Limit 0 for unlimited results."
            }
        }
        
        Write-Verbose "Getting tasks with parameters: $($params | ConvertTo-Json -Compress)"
        $uri = "$script:XoHost/rest/v0/tasks"
        $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body ($params | ConvertTo-Json -Compress) -Method Get
        
        if ($null -eq $response -or $response.Count -eq 0) {
            Write-Verbose "No tasks found with status: $Status"
            return
        }
        
        Write-Verbose "Found $($response.Count) tasks"
        
        # Apply limit if needed
        $tasksToProcess = $response
        if ($Limit -gt 0 -and $response.Count -gt $Limit) {
            $tasksToProcess = $response[0..($Limit-1)]
        }
        
        foreach ($taskUrl in $tasksToProcess) {
            if ($taskUrl -is [string] -and $taskUrl -match '/tasks/([0-9a-z]+)') {
                $id = $matches[1]
            
                Get-XoSingleTaskById -TaskId $id -Params $params
            }
            else {
                if ($taskUrl -is [PSObject] -or $taskUrl -is [Hashtable]) {
                    ConvertTo-XoTaskObject -InputObject $taskUrl
                }
                else {
                    Write-Verbose "Skipping unknown task format: $taskUrl"
                }
            }
        }
    } catch {
        throw ("Failed to retrieve tasks with status {0}: {1}" -f $Status, $_)
    }
}

New-Alias -Name Get-XoTaskDetails -Value Get-XoTask

function Wait-XoTask {
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

    begin {
        $params = @{
            fields = $script:XO_TASK_FIELDS
            wait   = "result"
        }
        $ids = @()
    }

    process {
        $ids += $TaskId
    }

    end {
        foreach ($id in $ids) {
            try {
                $uri = "$script:XoHost/rest/v0/tasks/$id"
                $result = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params
                
                if ($PassThru -and $result) {
                    ConvertTo-XoTaskObject -InputObject $result
                }
            }
            catch {
                throw ("Error waiting for task {0}: {1}" -f $id, $_)
            }
        }
    }
}

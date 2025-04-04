# SPDX-License-Identifier: Apache-2.0

$script:XO_TASK_FIELDS = "id,properties.method,start,status"

function ConvertTo-XoTaskObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        Set-XoObject $InputObject -TypeName XoPowershell.Task -Properties @{
            TaskId    = $InputObject.id
            Method    = $InputObject.properties.method
            StartTime = [System.DateTimeOffset]::FromUnixTimeMilliseconds($InputObject.start).ToLocalTime()
        }
    }
}

function ConvertFrom-XoTaskHref {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$Uri
    )

    process {
        if ($Uri -notmatch "\/rest\/v0\/tasks\/[0-9a-z]+") {
            throw "Bad task href format"
        }
        Get-XoTask ([uri]::new([uri]$script:XoHost, $Uri).Segments[-1])
    }
}

function Get-XoTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "TaskId")]
        [ValidatePattern("[0-9a-z]+")]
        [string[]]$TaskId,

        [Parameter(ParameterSetName = "Status")]
        [ValidateSet("pending", "success", "failure")]
        [string]$Status = "pending"
    )

    begin {
        $params = Remove-XoEmptyValues @{
            fields = $script:XO_TASK_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "TaskId") {
            foreach ($id in $TaskId) {
                ConvertTo-XoTaskObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/tasks/$($id)" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Status") {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/tasks" @script:XoRestParameters -Body @{
                fields = $script:XO_TASK_FIELDS
                filter = $Status
            }) | ConvertTo-XoTaskObject
        }
    }
}
New-Alias -Name Get-XoTaskDetails -Value Get-XoTask

function Wait-XoTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-z]+")]
        [string[]]$TaskId,
        [Parameter()][switch]$PassThru
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
            $result = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/tasks/$id" @script:XoRestParameters -Body $params
            if ($PassThru) {
                $result | ConvertTo-XoTaskObject
            }
        }
    }
}

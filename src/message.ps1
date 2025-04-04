$script:XO_MESSAGE_FIELDS = "body,name,time,type,uuid"

function ConvertTo-XoMessageObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            MessageUuid = $InputObject.uuid
            MessageTime = [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.time).ToLocalTime()
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Message -Properties $props
    }
}

function Get-XoMessage {
    <#
    .SYNOPSIS
        List or query messages.
    .DESCRIPTION
        Get Xen Orchestra messages by UUID or list all existing messages.
    .PARAMETER MessageUuid
        UUIDs of messages to query.
    .PARAMETER Limit
        Maximum number of results to return.
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "MessageUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$MessageUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Name,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit
    )

    begin {
        $params = @{
            fields = $script:XO_MESSAGE_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "MessageUuid") {
            foreach ($id in $MessageUuid) {
                ConvertTo-XoMessageObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/messages/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            $filter = ""

            if ($Name) {
                $filter = "$filter name:`"$Name`""
            }

            $params = Remove-XoEmptyValues @{
                filter = $filter
                fields = $script:XO_MESSAGE_FIELDS
            }

            if ($Limit) {
                $params["limit"] = $Limit
            }

            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/messages" @script:XoRestParameters -Body $params) | ConvertTo-XoMessageObject
        }
    }
}

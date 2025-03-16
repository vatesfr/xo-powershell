$script:XO_SR_FIELDS = "name_label,uuid,SR_type,content_type,allocationStrategy,size,physical_usage,usage,shared"

function ConvertTo-XoSrObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            SrUuid            = $InputObject.uuid
            Name              = $InputObject.name_label
            Type              = $InputObject.SR_type
            ContentType       = $InputObject.content_type
            SrSize            = Format-XoSize $InputObject.size
            UsageSize         = Format-XoSize $InputObject.usage
            PhysicalUsageSize = Format-XoSize $InputObject.physical_usage
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Sr -Properties $props
    }
}

function Get-XoSr {
    [CmdletBinding(DefaultParameterSetName = "All")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "SrId")]
        [ValidatePattern("[0-9a-z]+")]
        [string[]]$SrId
    )

    begin {
        $params = Remove-XoEmptyValues @{
            fields = $script:XO_SR_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "SrId") {
            foreach ($id in $SrId) {
                ConvertTo-XoSrObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/srs/$($id)" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "All") {
            $params = Remove-XoEmptyValues @{
                fields = $script:XO_SR_FIELDS
            }

            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/srs" @script:XoRestParameters -Body $params) | ConvertTo-XoSrObject
        }
    }
}

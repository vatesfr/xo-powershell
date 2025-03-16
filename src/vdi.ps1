$script:XO_VDI_FIELDS = "name_label,size,uuid"

function ConvertTo-XoVdiObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            VdiUuid = $InputObject.uuid
            Name    = $InputObject.name_label
            VdiSize = Format-XoSize $InputObject.size
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Vdi -Properties $props
    }
}

function Get-XoVdi {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VdiId")]
        [ValidatePattern("[0-9a-z]+")]
        [string[]]$VdiId
    )

    begin {
        $params = Remove-XoEmptyValues @{
            fields = $script:XO_VDI_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "VdiId") {
            foreach ($id in $VdiId) {
                ConvertTo-XoVdiObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vdis/$($id)" @script:XoRestParameters -Body $params)
            }
        }
    }
}

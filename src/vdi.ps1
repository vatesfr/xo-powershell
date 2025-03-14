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

$script:XO_VM_FIELDS = "name_label,name_description,power_state,uuid,addresses"

function ConvertTo-XoVmObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            VmUuid      = $InputObject.uuid
            Name        = $InputObject.name_label
            PowerState  = $InputObject.power_state
            IpAddresses = ""
        }
        if ($InputObject.power_state -ieq "Running") {
            $props["IpAddresses"] = $InputObject.addresses.PSObject.Properties | Where-Object MemberType -eq NoteProperty | Select-Object -ExpandProperty Value
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Vm -Properties $props
    }
}

# Get-XoVm has 3 parameter sets for specifying inputs in 3 ways:
# - Pipeline (... | get-xovm)
# - ID list (get-xovm aaaaa,bbbbb)
# - Queries (get-xovm -powerstate)
# This is a special treatment we reserve for commonly-used cmdlets.
function Get-XoVm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = "Pipeline")]
        $InputObject,

        [Parameter(Mandatory, Position = 0, ParameterSetName = "VmUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VmUuid,

        [Parameter(ParameterSetName = "PowerState")]
        [ValidateSet("Halted", "Paused", "Running", "Suspended")]
        [Alias("Status")]
        [string[]]$PowerState
    )

    begin {
        $params = @{
            fields = $script:XO_VM_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "Pipeline") {
            # faster than pipeline
            ConvertTo-XoVmObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$($InputObject.uuid)" @script:XoRestParameters -Body $params)
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "VmUuid") {
            foreach ($id in $VmUuid) {
                ConvertTo-XoVmObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id" @script:XoRestParameters -Body $params)
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq "PowerState") {
            $filter = ""
            if ($PowerState) {
                $filter += " power_state:|($($PowerState -join ' '))"
            }

            $params = Remove-XoEmptyValues @{
                filter = $filter
                fields = $script:XO_VM_FIELDS
            }

            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms" @script:XoRestParameters -Body $params) | ConvertTo-XoVmObject
        }
    }
}

function Get-XoVmVdi {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$VmUuid
    )

    begin {
        $params = @{
            fields = $XO_VDI_FIELDS
        }
    }

    process {
        (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid/vdis" @script:XoRestParameters -Body $params) | ConvertTo-XoVdiObject
    }
}

function Start-XoVm {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$VmUuid
    )

    process {
        if ($PSCmdlet.ShouldProcess($VmUuid, $action)) {
            Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid/actions/start" -Method Post @script:XoRestParameters | ForEach-Object {
                Get-XoTask $_.id
            }
        }
    }
}

function Stop-XoVm {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$VmUuid,
        [Parameter()][switch]$Force
    )

    begin {
        $action = if ($Force) { "hard_shutdown" } else { "clean_shutdown" }
    }

    process {
        if ($PSCmdlet.ShouldProcess($VmUuid, $action)) {
            Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid/actions/$action" -Method Post @script:XoRestParameters | ForEach-Object {
                Get-XoTask $_.id
            }
        }
    }
}

function Restart-XoVm {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$VmUuid,
        [Parameter()][switch]$Force
    )

    begin {
        $action = if ($Force) { "hard_reboot" } else { "clean_reboot" }
    }

    process {
        if ($PSCmdlet.ShouldProcess($VmUuid, $action)) {
            Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid/actions/$action" -Method Post @script:XoRestParameters | ForEach-Object {
                Get-XoTask $_.id
            }
        }
    }
}

function New-XoVmSnapshot {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$VmUuid,
        [Parameter()][string]$SnapshotName
    )

    begin {
        $params = Remove-XoEmptyValues @{
            name_label = $SnapshotName
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess($VmUuid, $action)) {
            Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid/actions/snapshot" -Method Post @script:XoRestParameters -Body $params | ForEach-Object {
                Get-XoTask $_.id
            }
        }
    }
}

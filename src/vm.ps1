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

# Get-XoVm has 2 parameter sets for specifying inputs in 3 ways:
# - ID list (get-xovm aaaaa,bbbbb)
# - Queries (get-xovm -powerstate)
# To add documentation, add a comment block (<##>) with a synopsis, then add parameter comments as below.
function Get-XoVm {
    <#
    .SYNOPSIS
        Query VMs by UUID or condition.
    #>
    [CmdletBinding()]
    param (
        # UUIDs of VMs to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VmUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VmUuid,

        # Power states of VMs to query.
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
        if ($PSCmdlet.ParameterSetName -eq "VmUuid") {
            foreach ($id in $VmUuid) {
                ConvertTo-XoVmObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "PowerState") {
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
        [string[]]$VmUuid
    )

    begin {
        $params = @{
            fields = $XO_VDI_FIELDS
        }
    }

    process {
        foreach ($id in $VmUuid) {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/vdis" @script:XoRestParameters -Body $params) | ConvertTo-XoVdiObject
        }
    }
}

function Start-XoVm {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid
    )

    process {
        foreach ($id in $VmUuid) {
            if ($PSCmdlet.ShouldProcess($VmUuid, "start")) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid/actions/start" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

function Stop-XoVm {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid,
        [Parameter()][switch]$Force
    )

    begin {
        $action = if ($Force) { "hard_shutdown" } else { "clean_shutdown" }
    }

    process {
        foreach ($id in $VmUuid) {
            if ($PSCmdlet.ShouldProcess($VmUuid, $action)) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid/actions/$action" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

function Restart-XoVm {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid,
        [Parameter()][switch]$Force
    )

    begin {
        $action = if ($Force) { "hard_reboot" } else { "clean_reboot" }
    }

    process {
        foreach ($id in $VmUuid) {
            if ($PSCmdlet.ShouldProcess($VmUuid, $action)) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid/actions/$action" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

function New-XoVmSnapshot {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid,
        [Parameter()][string]$SnapshotName
    )

    begin {
        $params = Remove-XoEmptyValues @{
            name_label = $SnapshotName
        }
    }

    process {
        foreach ($id in $VmUuid) {
            if ($PSCmdlet.ShouldProcess($VmUuid, "snapshot")) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid/actions/snapshot" -Method Post @script:XoRestParameters -Body $params | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

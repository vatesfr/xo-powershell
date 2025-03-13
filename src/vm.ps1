function Get-XoVm {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet("Halted", "Paused", "Running", "Suspended")]
        [string[]]$PowerState
    )

    $filter = ""
    if ($PowerState) {
        $filter += " power_state:|($($PowerState -join ' '))"
    }

    $params = Remove-XoEmptyValues @{
        filter = $filter
        fields = "name_label,name_description,power_state,uuid"
    }

    Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms" @script:XoRestParameters -Body $params | Set-XoObject -TypeName XoPowershell.Vm
}

function Get-XoVmVdi {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Uuid
    )

    begin {
        $params = Remove-XoEmptyValues @{
            fields = "name_label,size,uuid"
        }
    }

    process {
        $Uuid | ForEach-Object {
            Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$_/vdis" @script:XoRestParameters -Body $params
        } | Set-XoObject -TypeName XoPowershell.Vdi -Properties @{
            VmUuid = $Uuid
        }
    }
}

function Stop-XoVm {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Uuid,
        [Parameter()][switch]$Force
    )

    begin {
        $action = if ($Force) { "hard_shutdown" }else { "clean_shutdown" }
    }

    process {
        $Uuid | ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_, $action)) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$_/actions/$action" @script:XoRestParameters
            }
        }
    }
}

######

# Function to start,restart,shutdown vms on the xoa cluster
function XoVms-Action {
    param (
        [string]$VmId,
        [ValidateSet("start", "clean_reboot", "hard_reboot", "clean_shutdown", "hard_shutdown")]
        [string]$Action
    )
    $IsValid = Check-VmID($VmId)
    if (-not $IsValid) {
        Write-Error "Invalid VmID"
        return
    }
    $uri = "$script:XenOrchestraHost/rest/v0/vms/$VmId/actions/$Action"
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $script:headers -SkipCertificateCheck
    return $response
}

# Function to take a snapshot of a vms on the xoa cluster
function XoVms-Snapshot {
    param (
        [string]$VmId
    )
    $IsValid = Check-VmID($VmId)
    if (-not $IsValid) {
        Write-Error "Invalid VmID"
        return
    }
    $uri = "$script:XenOrchestraHost/rest/v0/vms/$VmId/actions/snapshot"
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $script:headers -SkipCertificateCheck
    return $response
}

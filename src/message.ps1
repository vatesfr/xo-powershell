# SPDX-License-Identifier: Apache-2.0

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
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        # UUIDs of messages to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "MessageUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$MessageUuid,

        # Find messages that match the specified name substring.
        [Parameter(ParameterSetName = "Filter")]
        [ArgumentCompletions("HA_STATEFILE_LOST", "HA_HEARTBEAT_APPROACHING_TIMEOUT", "HA_STATEFILE_APPROACHING_TIMEOUT", "HA_XAPI_HEALTHCHECK_APPROACHING_TIMEOUT", "HA_NETWORK_BONDING_ERROR", "HA_POOL_OVERCOMMITTED", "HA_POOL_DROP_IN_PLAN_EXISTS_FOR", "HA_PROTECTED_VM_RESTART_FAILED", "HA_HOST_FAILED", "HA_HOST_WAS_FENCED", "METADATA_LUN_HEALTHY", "METADATA_LUN_BROKEN", "IP_CONFIGURED_PIF_CAN_UNPLUG", "VIF_QOS_FAILED", "VBD_QOS_FAILED", "VCPU_QOS_FAILED", "VM_STARTED", "VM_SHUTDOWN", "VM_REBOOTED", "VM_MIGRATED", "VM_SNAPSHOTTED", "VM_SNAPSHOT_REVERTED", "VM_CHECKPOINTED", "VM_SUSPENDED", "VM_RESUMED", "VM_PAUSED", "VM_UNPAUSED", "VM_CRASHED", "VM_CLONED", "VM_SECURE_BOOT_FAILED", "HOST_SYNC_DATA_FAILED", "HOST_CLOCK_SKEW_DETECTED", "HOST_CLOCK_WENT_BACKWARDS", "POOL_MASTER_TRANSITION", "PBD_PLUG_FAILED_ON_SERVER_START", "ALARM", "WLB_CONSULTATION_FAILED", "WLB_OPTIMIZATION_ALERT", "EXTAUTH_INIT_IN_HOST_FAILED", "EXTAUTH_IN_POOL_IS_NON_HOMOGENEOUS", "MULTIPATH_PERIODIC_ALERT", "LICENSE_DOES_NOT_SUPPORT_POOLING", "LICENSE_EXPIRES_SOON", "LICENSE_EXPIRED", "LICENSE_SERVER_CONNECTED", "LICENSE_SERVER_UNAVAILABLE", "GRACE_LICENSE", "LICENSE_NOT_AVAILABLE", "LICENSE_SERVER_UNREACHABLE", "LICENSE_SERVER_VERSION_OBSOLETE", "PVS_PROXY_NO_CACHE_SR_AVAILABLE", "PVS_PROXY_SETUP_FAILED", "PVS_PROXY_NO_SERVER_AVAILABLE", "PVS_PROXY_SR_OUT_OF_SPACE", "VMPP_SNAPSHOT_LOCK_FAILED", "VMPP_SNAPSHOT_SUCCEEDED", "VMPP_SNAPSHOT_FAILED", "VMPP_ARCHIVE_LOCK_FAILED", "VMPP_ARCHIVE_FAILED_0", "VMPP_ARCHIVE_SUCCEEDED", "VMPP_ARCHIVE_TARGET_MOUNT_FAILED", "VMPP_ARCHIVE_TARGET_UNMOUNT_FAILED", "VMPP_LICENSE_ERROR", "VMPP_XAPI_LOGON_FAILURE", "VMPP_SNAPSHOT_MISSED_EVENT", "VMPP_ARCHIVE_MISSED_EVENT", "VMPP_SNAPSHOT_ARCHIVE_ALREADY_EXISTS", "VMSS_SNAPSHOT_LOCK_FAILED", "VMSS_SNAPSHOT_SUCCEEDED", "VMSS_SNAPSHOT_FAILED", "VMSS_LICENSE_ERROR", "VMSS_XAPI_LOGON_FAILURE", "VMSS_SNAPSHOT_MISSED_EVENT", "VDI_CBT_METADATA_INCONSISTENT", "VDI_CBT_SNAPSHOT_FAILED", "VDI_CBT_RESIZE_FAILED", "BOND_STATUS_CHANGED", "HOST_CPU_FEATURES_DOWN", "HOST_CPU_FEATURES_UP", "POOL_CPU_FEATURES_DOWN", "POOL_CPU_FEATURES_UP", "CLUSTER_QUORUM_APPROACHING_LOST", "CLUSTER_HOST_ENABLE_FAILED", "CLUSTER_HOST_FENCING", "CLUSTER_HOST_LEAVING", "CLUSTER_HOST_JOINING", "HOST_SERVER_CERTIFICATE_EXPIRED", "HOST_INTERNAL_CERTIFICATE_EXPIRED", "POOL_CA_CERTIFICATE_EXPIRED", "FAILED_LOGIN_ATTEMPTS", "HOST_KERNEL_ENCOUNTERED_ERROR_", "HOST_KERNEL_ENCOUNTERED_WARNING_", "TLS_VERIFICATION_EMERGENCY_DISABLED", "PERIODIC_UPDATE_SYNC_FAILED", "XAPI_STARTUP_BLOCKED_AS_VERSION_HIGHER_THAN_COORDINATOR", "ALL_RUNNING_VMS_IN_ANTI_AFFINITY_GRP_ON_SINGLE_HOST", "SM_GC_NO_SPACE")]
        [string]$Name,

        # Filter to apply to the message query.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "PoolUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PoolUuid,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VmUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$VmUuid,

        # Maximum number of results to return.
        [Parameter()]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        $params = @{
            fields = $script:XO_MESSAGE_FIELDS
        }

        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            $AllFilters = $Filter

            if ($Name) {
                $AllFilters = "$AllFilters name:`"$Name`""
            }

            $params = Remove-XoEmptyValues @{
                filter = $AllFilters
                fields = $script:XO_MESSAGE_FIELDS
            }
        }

        # numbers are not affected by Remove-XoEmptyValues
        # having $Limit be in ParameterSetName = "MessageUuid" is quite nonsensical, but hopefully better than having
        # a ton of ParameterSetNames.
        if ($Limit) {
            $params["limit"] = $Limit
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
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/messages" @script:XoRestParameters -Body $params) | ConvertTo-XoMessageObject
        }
        elseif ($PSCmdlet.ParameterSetName -eq "PoolUuid") {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$PoolUuid/messages" @script:XoRestParameters -Body $params) | ConvertTo-XoMessageObject
        }
        elseif ($PSCmdlet.ParameterSetName -eq "VmUuid") {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid/messages" @script:XoRestParameters -Body $params) | ConvertTo-XoMessageObject
        }
    }
}

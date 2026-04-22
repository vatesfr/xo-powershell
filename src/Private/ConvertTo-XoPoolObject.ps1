# SPDX-License-Identifier: Apache-2.0

$script:XO_POOL_FIELDS = "auto_poweron,default_SR,HA_enabled,haSrs,master,tags,name_description,name_label,migrationCompression,cpus,zstdSupported,vtpmSupported,platform_version,type,uuid"

function ConvertTo-XoPoolObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Pool object

    .DESCRIPTION
    Convert api object to powershell xo Pool object

    .PARAMETER InputObject
    Pool input object returned from the API.

    .EXAMPLE
    ConvertTo-XoPoolObject -InputObject $object

    #>
    [Cmdletbinding()]
    [OutputType("XoPowershell.Pool")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            PoolUuid        = $InputObject.uuid
            Name            = $InputObject.name_label
            Description     = $InputObject.name_description
            CpuCores        = $InputObject.cpus.cores
            PlatformVersion = $InputObject.platform_version
            HAEnabled       = $InputObject.HA_enabled
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Pool -Properties $props
    }
}

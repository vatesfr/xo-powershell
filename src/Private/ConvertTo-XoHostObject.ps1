# SPDX-License-Identifier: Apache-2.0

$script:XO_HOST_FIELDS = "uuid,name_label,name_description,power_state,memory,address,hostname,version,productBrand,build,startTime,tags,bios_strings,license_params,license_server,license_expiry,residentVms,PIFs,PCIs,PGPUs,poolId,CPUs"

function ConvertTo-XoHostObject
{
    <#
    .SYNOPSIS
        Convert a host object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a host object from the API to a PowerShell object with proper properties and types.
        This function creates a flat object using the raw values from the API response.
    .PARAMETER InputObject
        The host object from the API.
    .EXAMPLE
        ConvertTo-XoHostObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Host")]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            HostUuid      = $InputObject.uuid
            Name          = $InputObject.name_label
            PowerState    = $InputObject.power_state
            Description   = $InputObject.name_description
            BiosStrings   = $InputObject.bios_strings
            LicenseParams = $InputObject.license_params
            LicenseServer = $InputObject.license_server
            LicenseExpiry = $InputObject.license_expiry
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Host -Properties $props
    }
}

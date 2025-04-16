# SPDX-License-Identifier: Apache-2.0

$script:XO_SR_FIELDS = "name_label,uuid,SR_type,content_type,allocationStrategy,size,physical_usage,usage,shared"

function ConvertTo-XoSrObject {
    <#
    .SYNOPSIS
        Convert a storage repository object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a storage repository object from the API to a PowerShell object with proper properties and types.
    .PARAMETER InputObject
        The storage repository object from the API.
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Sr")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        $InputObject
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

function Get-XoSingleSrById {
    param (
        [string]$SrUuid,
        [hashtable]$Params
    )

    try {
        Write-Verbose "Getting SR with UUID $SrUuid"
        $uri = "$script:XoHost/rest/v0/srs/$SrUuid"
        $srData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $Params

        if ($srData) {
            return ConvertTo-XoSrObject -InputObject $srData
        }
    }
    catch {
        throw ("Failed to retrieve SR with UUID {0}: {1}" -f $SrUuid, $_)
    }
    return $null
}

function Get-XoSr {
    <#
    .SYNOPSIS
        Get storage repositories from Xen Orchestra.
    .DESCRIPTION
        Retrieves storage repositories from Xen Orchestra. Can retrieve specific SRs by their UUID
        or all SRs.
    .PARAMETER SrUuid
        The UUID(s) of the SR(s) to retrieve.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
        Use -Limit 0 to return all results without limitation.
    .EXAMPLE
        Get-XoSr
        Returns up to 25 SRs.
    .EXAMPLE
        Get-XoSr -Limit 0
        Returns all SRs without limit.
    .EXAMPLE
        Get-XoSr -SrUuid "a1b2c3d4"
        Returns the SR with the specified UUID.
    .EXAMPLE
        Get-XoSr -Limit 5
        Returns the first 5 SRs.
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    # Parameter sets:
    # - "Filter": Gets SRs with optional filtering criteria (with optional limit)
    # - "SrUuid": Gets specific SRs by UUID
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "SrUuid")]
        [ValidatePattern("[0-9a-z-]+")]
        [Alias("SrId")]
        [string[]]$SrUuid,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $params = @{
            fields = $script:XO_SR_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "SrUuid") {
            foreach ($id in $SrUuid) {
                Get-XoSingleSrById -SrUuid $id -Params $params
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            if ($Limit) {
                $params['limit'] = $Limit
            }

            try {
                Write-Verbose "Getting SRs with parameters: $($params | ConvertTo-Json -Compress)"
                $uri = "$script:XoHost/rest/v0/srs"
                $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if (!$response -or $response.Count -eq 0) {
                    Write-Verbose "No SRs found"
                    return
                }

                Write-Verbose "Found $($response.Count) SRs"

                foreach ($srItem in $response) {
                    ConvertTo-XoSrObject -InputObject $srItem
                }
            }
            catch {
                throw ("Failed to list SRs. Error: {0}" -f $_)
            }
        }
    }
}

function Set-XoSr {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("SrId")]
        [string]$SrUuid,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string[]]$Tags
    )

    $params = @{}

    if ($PSBoundParameters.ContainsKey("Name")) {
        $params["name_label"] = $Name
    }
    if ($PSBoundParameters.ContainsKey("Description")) {
        $params["name_description"] = $Description
    }
    if ($PSBoundParameters.ContainsKey("Tags")) {
        $params["tags"] = $Tags
    }

    if ($params.Count -gt 0) {
        $body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $params))
        Invoke-RestMethod -Uri "$script:XoHost/rest/v0/srs/$SrUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
    }
}

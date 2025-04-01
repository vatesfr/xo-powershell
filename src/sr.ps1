# SPDX-License-Identifier: Apache-2.0

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
    <#
    .SYNOPSIS
        Get storage repositories from Xen Orchestra.
    .DESCRIPTION
        Retrieves storage repositories from Xen Orchestra. Can retrieve specific SRs by their ID
        or all SRs.
    .PARAMETER SrId
        The ID(s) of the SR(s) to retrieve.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoSr
        Returns up to 25 SRs.
    .EXAMPLE
        Get-XoSr -Limit 0
        Returns all SRs without limit.
    .EXAMPLE
        Get-XoSr -SrId "a1b2c3d4"
        Returns the SR with the specified ID.
    .EXAMPLE
        Get-XoSr -Limit 5
        Returns the first 5 SRs.
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "SrId")]
        [ValidatePattern("[0-9a-z-]+")]
        [string[]]$SrId,

        [Parameter(ParameterSetName = "All")]
        [int]$Limit = 25
    )

    begin {
        $params = @{
            fields = $script:XO_SR_FIELDS
        }
        
        if ($Limit -ne 0) {
            $params['limit'] = $Limit
            if (!$PSBoundParameters.ContainsKey('Limit')) {
                Write-Warning "No limit specified. Using default limit of 25. Use -Limit 0 for unlimited results."
            }
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "SrId") {
            foreach ($id in $SrId) {
                try {
                    $srData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/srs/$($id)" @script:XoRestParameters -Body $params
                    if ($srData) {
                        ConvertTo-XoSrObject $srData
                    }
                }
                catch {
                    throw "Failed to retrieve SR with ID $id. Error: $_"
                }
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "All") {
            try {
                Write-Verbose "Getting SRs with parameters: $($params | ConvertTo-Json -Compress)"
                $allSrData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/srs" @script:XoRestParameters -Body $params
                
                if ($allSrData -and $allSrData.Count -gt 0) {
                    Write-Verbose "Found $($allSrData.Count) SRs"
                    
                    foreach ($srItem in $allSrData) {
                        try {                            
                            if ($srItem -is [string] -and $srItem -match "\/rest\/v0\/srs\/([^\/]+)$") {

                                $id = $matches[1]
                                Write-Verbose "Fetching SR details for ID $id from URL"
                                $srDetail = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/srs/$id" @script:XoRestParameters
                                if ($srDetail) {
                                    ConvertTo-XoSrObject $srDetail
                                }
                            }
                            elseif ($srItem -is [PSCustomObject] -or $srItem -is [Hashtable]) {
                                Write-Verbose "Processing SR object directly"
                                ConvertTo-XoSrObject $srItem
                            }
                            else {
                                throw "Unexpected SR data format: $($srItem.GetType().Name)"
                            }
                        }
                        catch {
                            throw "Failed to process SR data. Error: $_"
                        }
                    }
                }
                else {
                    Write-Verbose "No SRs found"
                }
            }
            catch {
                throw "Failed to retrieve SRs: $_"
            }
        }
    }
}

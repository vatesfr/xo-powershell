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
        Maximum number of results to return when retrieving all SRs.
    .EXAMPLE
        Get-XoSr
        Returns all SRs.
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
        [ValidatePattern("[0-9a-z]+")]
        [string[]]$SrId,
        
        [Parameter(ParameterSetName = "All")]
        [int]$Limit
    )

    begin {
        $params = @{}
        if ($PSBoundParameters.ContainsKey('Limit')) {
            $params['limit'] = $Limit
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "SrId") {
            foreach ($id in $SrId) {
                try {
                    $srData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/srs/$($id)" @script:XoRestParameters
                    if ($srData) {
                        ConvertTo-XoSrObject $srData
                    }
                }
                catch {
                    Write-Error "Failed to retrieve SR with ID $id. Error: $_"
                }
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "All") {
            try {
                Write-Verbose "Getting all SRs"
                $allSrUrls = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/srs" @script:XoRestParameters
                
                if ($allSrUrls -and $allSrUrls.Count -gt 0) {
                    Write-Verbose "Found $($allSrUrls.Count) SRs"
                    
                    # Apply limit if specified
                    $processLimit = if ($Limit -gt 0) { [Math]::Min($Limit, $allSrUrls.Count) } else { $allSrUrls.Count }
                    $processUrls = $allSrUrls | Select-Object -First $processLimit
                    
                    foreach ($srUrl in $processUrls) {
                        # Skip null or empty URLs
                        if ([string]::IsNullOrEmpty($srUrl)) {
                            Write-Verbose "Skipping empty URL"
                            continue
                        }
                        
                        try {
                            # Extract the ID from the URL string
                            $match = [regex]::Match($srUrl, "\/rest\/v0\/srs\/([^\/]+)$")
                            if ($match.Success) {
                                $id = $match.Groups[1].Value
                                if (![string]::IsNullOrEmpty($id)) {
                                    $srDetail = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/srs/$id" @script:XoRestParameters
                                    if ($srDetail) {
                                        ConvertTo-XoSrObject $srDetail
                                    }
                                }
                                else {
                                    Write-Warning "Failed to extract valid ID from URL: $srUrl"
                                }
                            }
                            else {
                                Write-Warning "URL doesn't match expected pattern: $srUrl"
                            }
                        }
                        catch {
                            Write-Warning "Failed to process SR from URL $srUrl. Error: $_"
                        }
                    }
                    
                    if ($allSrUrls.Count -gt $processLimit) {
                        Write-Warning "Only processed $processLimit of $($allSrUrls.Count) available SRs. Use -Limit parameter to adjust."
                    }
                }
                else {
                    Write-Verbose "No SRs found"
                }
            }
            catch {
                Write-Error "Failed to retrieve SRs: $_"
            }
        }
    }
}

# SPDX-License-Identifier: Apache-2.0

function New-XoVdi
{
    <#
    .SYNOPSIS
        Create a new Xen Orchestra VDI on a storage repository.
    .DESCRIPTION
        Calls POST /vdis to create an empty VDI of the specified size on the given SR. Returns the created VDI (resolved via Get-XoVdi) or the raw server response.
    .PARAMETER SrUuid
        The UUID of the SR to create the VDI on.
    .PARAMETER Name
        Name label for the new VDI.
    .PARAMETER SizeBytes
        Virtual size of the VDI, in bytes.
    .PARAMETER Description
        Optional name_description for the new VDI.
    .EXAMPLE
        New-XoVdi -SrUuid "<sr>" -Name "scratch" -SizeBytes 10737418240
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Vdi")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$SrUuid,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory, Position = 2)]
        [ValidateRange(1, [long]::MaxValue)]
        [long]$SizeBytes,

        [Parameter()]
        [string]$Description
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }
    }

    process
    {
        if (-not $PSCmdlet.ShouldProcess($Name, "create VDI on SR $SrUuid"))
        {
            return
        }

        $body = @{
            srId         = $SrUuid
            name_label   = $Name
            virtual_size = $SizeBytes
        }
        if ($PSBoundParameters.ContainsKey("Description")) { $body["name_description"] = $Description }

        $bodyJson  = ConvertTo-Json -InputObject $body -Depth 5 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

        $uri = "$script:XoHost/rest/v0/vdis"
        $response = Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes

        $newId = $null
        if ($response -is [string] -and $response -match '\/rest\/v0\/vdis\/([0-9a-f-]+)')
        {
            $newId = $matches[1]
        }
        elseif ($response -and $response.PSObject.Properties.Name -contains 'id')
        {
            $newId = $response.id
        }

        if ($newId)
        {
            # XO may take a moment to publish the new VDI via GET, so fall back to a
            # lightweight object if the follow-up lookup fails.
            try
            {
                Get-XoVdi -VdiUuid $newId -ErrorAction Stop
            }
            catch
            {
                Write-Verbose "Get-XoVdi failed after create ($_); returning a stub."
                [PSCustomObject]@{
                    PSTypeName = 'XoPowershell.Vdi'
                    VdiUuid    = $newId
                    Name       = $Name
                    SrUuid     = $SrUuid
                    Size       = $SizeBytes
                }
            }
        }
        else
        {
            $response
        }
    }
}

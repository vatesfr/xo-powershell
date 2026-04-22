# SPDX-License-Identifier: Apache-2.0

function Set-XoPif
{
    <#
    .SYNOPSIS
    Set Pif

    .DESCRIPTION
    Update properties of a PIF in Xen Orchestra.

    .PARAMETER PifUuid
    UUID of the PIF to update.

    .PARAMETER Name
    New name label for the PIF.

    .PARAMETER Description
    New description for the PIF.

    .PARAMETER Tags
    Tags to assign to the target PIF.

    .EXAMPLE
    Set-XoPif -PifUuid '011ccf6a-c5ad-48ec-a255-d056584686f0' -Name 'New Name'
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("PifId")]
        [string]$PifUuid,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string[]]$Tags
    )
    process {
    # NOTE: the current Xen Orchestra REST API does not expose a PATCH endpoint at /pifs/{id}.
    # This cmdlet is kept for backwards compatibility but will fail against modern XO releases.
    Write-Warning "Set-XoPif targets PATCH /pifs/{id}, which the current XO REST API does not expose. The call will likely fail."


        $params = @{}

        if ($PSBoundParameters.ContainsKey("Name"))
        {
            $params["name_label"] = $Name
        }
        if ($PSBoundParameters.ContainsKey("Description"))
        {
            $params["name_description"] = $Description
        }
        if ($PSBoundParameters.ContainsKey("Tags"))
        {
            $params["tags"] = $Tags
        }

        if ($params.Count -gt 0)
        {
            if ($PSCmdlet.ShouldProcess($PifUuid, "Set Pif on target "))
            {

                $body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $params))
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pifs/$PifUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
            }
        }
    }
}


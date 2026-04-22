# SPDX-License-Identifier: Apache-2.0

function Set-XoVif
{
    <#
    .SYNOPSIS
    Set Vif

    .DESCRIPTION
    Update properties of a VIF in Xen Orchestra.

    .PARAMETER VifUuid
    UUID of the VIF to update.

    .PARAMETER Name
    New name label for the VIF.

    .PARAMETER Description
    New description for the VIF.

    .PARAMETER Tags
    Tags to assign to the target VIF.

    .EXAMPLE
    Set-XoVif -VifUuid '812b59e1-2682-43ef-acd4-808d3551b907' -Name 'MyVif'
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("VifId")]
        [string]$VifUuid,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string[]]$Tags
    )
    process {
    # NOTE: the current Xen Orchestra REST API does not expose a PATCH endpoint at /vifs/{id}.
    # This cmdlet is kept for backwards compatibility but will fail against modern XO releases.
    Write-Warning "Set-XoVif targets PATCH /vifs/{id}, which the current XO REST API does not expose. The call will likely fail."


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
            if ($PSCmdlet.ShouldProcess($VifUuid, "Set Vif on Target"))
            {

                $body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $params))
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vifs/$VifUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
            }
        }
    }
}


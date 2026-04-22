# SPDX-License-Identifier: Apache-2.0

function Set-XoVdi
{
    <#
    .SYNOPSIS
    Set XO VDI

    .DESCRIPTION
    Update properties of a VDI in Xen Orchestra.

    .PARAMETER VdiUuid
    UUID of the VDI to update.

    .PARAMETER Name
    New name label for the VDI.

    .PARAMETER Description
    New description for the target VDI.

    .EXAMPLE
    Set-XoVdi -VdiUuid '011ccf6a-c5ad-48ec-a255-d056584686f0' -Name 'MyVdi'

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("VdiId")]
        [string]$VdiUuid,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Description
    )
    process {
    # NOTE: the current Xen Orchestra REST API does not expose a PATCH endpoint at /vdis/{id}.
    # This cmdlet is kept for backwards compatibility but will fail against modern XO releases.
    Write-Warning "Set-XoVdi targets PATCH /vdis/{id}, which the current XO REST API does not expose. The call will likely fail."


        $params = @{}

        if ($PSBoundParameters.ContainsKey("Name"))
        {
            $params["name_label"] = $Name
        }
        if ($PSBoundParameters.ContainsKey("Description"))
        {
            $params["name_description"] = $Description
        }

        if ($params.Count -gt 0)
        {
            if ($PSCmdlet.ShouldProcess($VdiUuid, "Set VDI on target"))
            {

                $body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $params))
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vdis/$VdiUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
            }
        }
    }
}


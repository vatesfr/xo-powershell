# SPDX-License-Identifier: Apache-2.0

function Set-XoSr
{
    <#
    .SYNOPSIS
    Set XO sr

    .DESCRIPTION
    Update properties of a storage repository in XO.

    .PARAMETER SrUuid
    UUID of the storage repository to update.

    .PARAMETER Name
    New name label for the SR.

    .PARAMETER Description
    New description for the SR.

    .PARAMETER Tags
    Tags to assign to the target SR.

    .EXAMPLE
    Set-XoSr -SrUuid '011ccf6a-c5ad-48ec-a255-d056584686f0' -Name "MySR"

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
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
    process {
    # NOTE: the current Xen Orchestra REST API does not expose a PATCH endpoint at /srs/{id}.
    # This cmdlet is kept for backwards compatibility but will fail against modern XO releases.
    Write-Warning "Set-XoSr targets PATCH /srs/{id}, which the current XO REST API does not expose. The call will likely fail."


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
            if ($PSCmdlet.ShouldProcess($SrUuid, "Set SR on target"))
            {

                $body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $params))
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/srs/$SrUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
            }
        }
    }
}


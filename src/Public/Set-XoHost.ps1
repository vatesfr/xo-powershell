# SPDX-License-Identifier: Apache-2.0

function Set-XoHost
{
    <#
    .SYNOPSIS
    Set Host

    .DESCRIPTION
    Update properties of a host in Xen Orchestra.

    .PARAMETER HostUuid
    UUID of the host to update.

    .PARAMETER Name
    New name label for the host.

    .PARAMETER Description
    New description for the host.

    .PARAMETER Tags
    Tags to assign to the target host.

    .EXAMPLE
    Set-XoHost -HostUuid '011ccf6a-c5ad-48ec-a255-d056584686f0' -Name 'MyHost' -Description 'First Host' -Tags @('Critical','Backups')
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("HostId")]
        [string]$HostUuid,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string[]]$Tags
    )
    process {
    # NOTE: the current Xen Orchestra REST API does not expose a PATCH endpoint at /hosts/{id}.
    # This cmdlet is kept for backwards compatibility but will fail against modern XO releases.
    Write-Warning "Set-XoHost targets PATCH /hosts/{id}, which the current XO REST API does not expose. The call will likely fail."


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
            if ($PSCmdlet.ShouldProcess($HostUuid, 'Set Host'))
            {

                $body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $params))
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/hosts/$HostUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
            }
        }
    }
}


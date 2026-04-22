# SPDX-License-Identifier: Apache-2.0

function Set-XoNetwork
{
    <#
    .SYNOPSIS
    Set XO Network

    .DESCRIPTION
    Update properties of a network in Xen Orchestra.

    .PARAMETER NetworkUuid
    UUID of the network to update.

    .PARAMETER Name
    New name label for the network.

    .PARAMETER Description
    Target network description

    .PARAMETER Tags
    Tags to assign to the target network.

    .EXAMPLE
    $params = @{
        NetworkUuid = '011ccf6a-c5ad-48ec-a255-d056584686f0'
        Name = 'MyNetwork'
        Description = "My awesome network"
        Tags = @('Important', 'MainNetwork')
    }
    Set-XoNetwork @params
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("NetworkId")]
        [string]$NetworkUuid,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string[]]$Tags
    )
    process {
    # NOTE: the current Xen Orchestra REST API does not expose a PATCH endpoint at /networks/{id}.
    # This cmdlet is kept for backwards compatibility but will fail against modern XO releases.
    Write-Warning "Set-XoNetwork targets PATCH /networks/{id}, which the current XO REST API does not expose. The call will likely fail."


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
            if ($PSCmdlet.ShouldProcess($NetworkUuid, "Set network target "))
            {
                $body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $params))
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/networks/$NetworkUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
            }
        }
    }
}


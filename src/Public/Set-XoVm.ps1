# SPDX-License-Identifier: Apache-2.0

function Set-XoVm
{
    <#
    .SYNOPSIS
    Set Vm

    .DESCRIPTION
    Update properties of a VM in Xen Orchestra.

    .PARAMETER VmUuid
    UUID of the target VM to update.

    .PARAMETER Name
    New name label for the VM.

    .PARAMETER Description
    New description for the VM.

    .PARAMETER Tags
    Tags to assign to the target VM.

    .EXAMPLE
    Set-XoVm -VmUuid '812b59e1-2682-43ef-acd4-808d3551b907' -Name 'MyVm'
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("VmId")]
        [string]$VmUuid,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string[]]$Tags
    )
    process {
    # NOTE: the current Xen Orchestra REST API does not expose a PATCH endpoint at /vms/{id}.
    # This cmdlet is kept for backwards compatibility but will fail against modern XO releases.
    Write-Warning "Set-XoVm targets PATCH /vms/{id}, which the current XO REST API does not expose. The call will likely fail."


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
            if ($PSCmdlet.ShouldProcess($VmUuid, "Set VM target"))
            {
                $body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $params))
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
            }
        }
    }

}


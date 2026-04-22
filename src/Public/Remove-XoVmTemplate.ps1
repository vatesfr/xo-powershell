# SPDX-License-Identifier: Apache-2.0

function Remove-XoVmTemplate
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra VM templates.
    .DESCRIPTION
        Issues DELETE /vm-templates/{id}. Accepts multiple IDs and pipeline input by property name.
    .PARAMETER VmTemplateUuid
        The ID(s) of the VM template(s) to delete.
    .EXAMPLE
        Remove-XoVmTemplate -VmTemplateUuid "<id>"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmTemplateUuid
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
        foreach ($id in $VmTemplateUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete VM template"))
            {
                $uri = "$script:XoHost/rest/v0/vm-templates/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

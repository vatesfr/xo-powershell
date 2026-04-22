# SPDX-License-Identifier: Apache-2.0

function Get-XoVmController
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra VM controllers.
    .DESCRIPTION
        Retrieves VM controllers (dom0 control-domain VMs) from Xen Orchestra. These are the privileged VMs that run on each host to manage guest VMs. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -VmControllerUuid to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER VmControllerUuid
        One or more IDs of the VM controllers to retrieve. When omitted, the cmdlet enumerates VM controllers using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of VM controllers to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoVmController
    .EXAMPLE
        Get-XoVmController -VmControllerUuid "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.VmController")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VmControllerUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VmControllerUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $params = @{}

    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "VmControllerUuid")
        {
            foreach ($id in $VmControllerUuid)
            {
                $uri = "$script:XoHost/rest/v0/vm-controllers/$id"
                ConvertTo-XoVmControllerObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/vm-controllers"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoVmControllerObject
        }
    }
}


# SPDX-License-Identifier: Apache-2.0

function New-XoVm
{
    <#
    .SYNOPSIS
        Create a new VM on a Xen Orchestra pool.
    .DESCRIPTION
        Creates a new VM on the specified pool from a VM template. Thin wrapper around the
        internal Invoke-XoPoolAction -Action create_vm helper. Returns a task object that
        can be passed to Wait-XoTask to monitor completion.
    .PARAMETER PoolUuid
        The UUID of the pool to create the VM on.
    .PARAMETER Name
        The name_label to assign to the new VM.
    .PARAMETER TemplateUuid
        The UUID of the VM template to clone from. See Get-XoVmTemplate.
    .PARAMETER Description
        Optional name_description for the new VM.
    .PARAMETER HostUuid
        Optional UUID of the host the VM should prefer (affinity). See Get-XoHost.
    .PARAMETER CPUs
        Optional number of virtual CPUs to assign to the new VM.
    .PARAMETER MemoryBytes
        Optional amount of memory, in bytes, to assign to the new VM.
    .PARAMETER AdditionalParameters
        Optional hashtable of extra body parameters to merge into the create_vm action
        payload. Values in this hashtable override any of the dedicated parameters above.
    .EXAMPLE
        New-XoVm -PoolUuid $pool.PoolUuid -Name "web-01" -TemplateUuid $tpl.VmTemplateUuid
    .EXAMPLE
        New-XoVm -PoolUuid $pool.PoolUuid -Name "web-01" -TemplateUuid $tpl.VmTemplateUuid -HostUuid $host.HostUuid -CPUs 2 -MemoryBytes 2147483648
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$PoolUuid,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [Alias("TemplateId")]
        [string]$TemplateUuid,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [Alias("AffinityHost")]
        [string]$HostUuid,

        [Parameter()]
        [ValidateRange(1, 4096)]
        [int]$CPUs,

        [Parameter()]
        [ValidateRange(1, [long]::MaxValue)]
        [long]$MemoryBytes,

        [Parameter()]
        [hashtable]$AdditionalParameters
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
        if (-not $PSCmdlet.ShouldProcess($Name, "create VM on pool $PoolUuid"))
        {
            return
        }

        $params = @{
            name_label = $Name
            template   = $TemplateUuid
        }

        if ($PSBoundParameters.ContainsKey("Description"))
        {
            $params["name_description"] = $Description
        }
        if ($PSBoundParameters.ContainsKey("HostUuid"))
        {
            $params["affinity"] = $HostUuid
        }
        if ($PSBoundParameters.ContainsKey("CPUs"))
        {
            # swagger expects lowercase "cpus" in the create_vm body
            $params["cpus"] = $CPUs
        }
        if ($PSBoundParameters.ContainsKey("MemoryBytes"))
        {
            $params["memory"] = $MemoryBytes
        }

        if ($AdditionalParameters)
        {
            foreach ($key in $AdditionalParameters.Keys)
            {
                $params[$key] = $AdditionalParameters[$key]
            }
        }

        Invoke-XoPoolAction -PoolUuid $PoolUuid -Action "create_vm" -ActionParameters $params
    }
}

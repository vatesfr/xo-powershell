# SPDX-License-Identifier: Apache-2.0

function New-XoVif
{
    <#
    .SYNOPSIS
        Create a new Xen Orchestra VIF attaching a VM to a network.
    .DESCRIPTION
        Calls POST /vifs to add a new virtual network interface to the specified VM on the specified network.
    .PARAMETER VmUuid
        The UUID of the VM to attach the VIF to.
    .PARAMETER NetworkUuid
        The UUID of the network to connect the VIF to.
    .PARAMETER Mac
        Optional MAC address. If omitted, XO generates one.
    .EXAMPLE
        New-XoVif -VmUuid "<vm>" -NetworkUuid "<network>"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Vif")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$VmUuid,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$NetworkUuid,

        [Parameter()]
        [string]$Mac
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
        if (-not $PSCmdlet.ShouldProcess("VM $VmUuid", "attach VIF on network $NetworkUuid"))
        {
            return
        }

        $body = @{
            vmId      = $VmUuid
            networkId = $NetworkUuid
        }
        if ($PSBoundParameters.ContainsKey("Mac")) { $body["mac"] = $Mac }

        $bodyJson  = ConvertTo-Json -InputObject $body -Depth 5 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

        $uri = "$script:XoHost/rest/v0/vifs"
        Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes
    }
}

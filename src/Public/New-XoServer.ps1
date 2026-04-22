# SPDX-License-Identifier: Apache-2.0

function New-XoServer
{
    <#
    .SYNOPSIS
        Register a new XCP-ng/XenServer pool master with Xen Orchestra.
    .DESCRIPTION
        Calls POST /servers to add a pool master. The credentials are supplied as a PSCredential so the password is not exposed in plain text. Label and connection flags are optional; host/username/password are mandatory.
    .PARAMETER HostName
        The IP address or hostname of the pool master to register.
    .PARAMETER Credential
        PSCredential with the XCP-ng root (or equivalent) username and password.
    .PARAMETER Label
        Optional friendly label shown in the XO UI.
    .PARAMETER AllowUnauthorized
        Accept self-signed certificates when connecting to the pool master.
    .EXAMPLE
        New-XoServer -Host "192.168.1.10" -Credential (Get-Credential root) -Label "lab pool"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Server")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$HostName,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNull()]
        [pscredential]$Credential,

        [Parameter()]
        [string]$Label,

        [Parameter()]
        [switch]$AllowUnauthorized
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
        if (-not $PSCmdlet.ShouldProcess($Host, "register XO server"))
        {
            return
        }

        $body = @{
            host              = $Host
            username          = $Credential.UserName
            password          = $Credential.GetNetworkCredential().Password
            allowUnauthorized = [bool]$AllowUnauthorized
        }
        if ($PSBoundParameters.ContainsKey("Label"))
        {
            $body["label"] = $Label
        }

        $bodyJson = ConvertTo-Json -InputObject $body -Depth 5 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

        $uri = "$script:XoHost/rest/v0/servers"
        $response = Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes

        if ($response -is [string] -and $response -match '\/rest\/v0\/servers\/([0-9a-f-]+)')
        {
            Get-XoServer -ServerUuid $matches[1]
        }
        elseif ($response -and $response.PSObject.Properties.Name -contains 'id')
        {
            Get-XoServer -ServerUuid $response.id
        }
        else
        {
            $response
        }
    }
}

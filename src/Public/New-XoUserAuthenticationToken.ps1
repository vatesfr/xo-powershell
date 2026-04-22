# SPDX-License-Identifier: Apache-2.0

function New-XoUserAuthenticationToken
{
    <#
    .SYNOPSIS
        Create a new API authentication token for a user.
    .DESCRIPTION
        Calls POST /users/{id}/authentication_tokens to mint a new XO API token. The token value is returned once; store it securely.
    .PARAMETER UserId
        The UUID of the user the token is minted for.
    .PARAMETER Description
        Human-readable description of what the token is for.
    .PARAMETER ClientId
        Optional stable client identifier to associate with the token.
    .PARAMETER ExpiresIn
        Optional expiration expressed as an XO duration string (e.g. '1 hour', '30 days').
    .EXAMPLE
        New-XoUserAuthenticationToken -UserId "<user>" -Description "ci pipeline" -ExpiresIn "30 days"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$UserId,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string]$ClientId,

        [Parameter()]
        [string]$ExpiresIn
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
        if (-not $PSCmdlet.ShouldProcess($UserId, "create authentication token"))
        {
            return
        }

        $body = @{}
        if ($PSBoundParameters.ContainsKey("Description")) { $body["description"] = $Description }
        if ($PSBoundParameters.ContainsKey("ClientId"))    { $body["client"]      = @{ id = $ClientId } }
        if ($PSBoundParameters.ContainsKey("ExpiresIn"))   { $body["expiresIn"]   = $ExpiresIn }

        $bodyJson  = ConvertTo-Json -InputObject $body -Depth 5 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

        $uri = "$script:XoHost/rest/v0/users/$UserId/authentication_tokens"
        Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes
    }
}

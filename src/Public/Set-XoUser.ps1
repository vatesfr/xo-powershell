# SPDX-License-Identifier: Apache-2.0

function Set-XoUser
{
    <#
    .SYNOPSIS
        Update a Xen Orchestra user.
    .DESCRIPTION
        Edits an existing user via PATCH /users/{id}. Any combination of Credential, Permission, or Preferences may be supplied; omitted fields are left unchanged. When Credential is supplied, both the user name and password are sent (XO treats them as a pair on update).
    .PARAMETER UserId
        The UUID of the user to update.
    .PARAMETER Credential
        PSCredential holding the new user name and password to assign. The UserName is sent as 'name' and the password is sent in the request body.
    .PARAMETER Permission
        New permission level: 'none', 'viewer', or 'admin'.
    .PARAMETER Preferences
        Hashtable of preference key/values to store on the user.
    .EXAMPLE
        Set-XoUser -UserId "722d17b9-699b-49d2-8193-be1ac573d3de" -Permission admin
    .EXAMPLE
        Set-XoUser -UserId "722d17b9-699b-49d2-8193-be1ac573d3de" -Credential (Get-Credential)
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$UserId,

        [Parameter()]
        [ValidateNotNull()]
        [pscredential]$Credential,

        [Parameter()]
        [ValidateSet("none", "viewer", "admin")]
        [string]$Permission,

        [Parameter()]
        [hashtable]$Preferences
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
        $params = @{}
        if ($PSBoundParameters.ContainsKey("Credential"))
        {
            $params["name"]     = $Credential.UserName
            $params["password"] = $Credential.GetNetworkCredential().Password
        }
        if ($PSBoundParameters.ContainsKey("Permission"))  { $params["permission"]  = $Permission }
        if ($PSBoundParameters.ContainsKey("Preferences")) { $params["preferences"] = $Preferences }

        if ($params.Count -eq 0) { return }

        if (-not $PSCmdlet.ShouldProcess($UserId, "update user"))
        {
            return
        }

        $bodyJson  = ConvertTo-Json -InputObject $params -Depth 10 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

        $uri = "$script:XoHost/rest/v0/users/$UserId"
        Invoke-RestMethod -Uri $uri -Method Patch @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes
    }
}

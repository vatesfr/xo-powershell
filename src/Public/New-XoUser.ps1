# SPDX-License-Identifier: Apache-2.0

function New-XoUser
{
    <#
    .SYNOPSIS
        Create a new Xen Orchestra user.
    .DESCRIPTION
        Creates a new user via POST /users. The name and password are supplied together as a PSCredential so the password never has to sit in a plain-text variable. Permission defaults to 'none' (read-only).
    .PARAMETER Credential
        PSCredential whose UserName becomes the XO user name and whose Password is sent to XO as the initial password.
    .PARAMETER Permission
        Permission level for the new user: 'none', 'viewer' (read-only), or 'admin'. Defaults to 'none'.
    .EXAMPLE
        New-XoUser -Credential (Get-Credential) -Permission viewer
    .EXAMPLE
        $cred = [pscredential]::new("alice@example.com", (ConvertTo-SecureString "s3cret" -AsPlainText -Force))
        New-XoUser -Credential $cred
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.User")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNull()]
        [pscredential]$Credential,

        [Parameter()]
        [ValidateSet("none", "viewer", "admin")]
        [string]$Permission = "none"
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
        $userName = $Credential.UserName
        if (-not $PSCmdlet.ShouldProcess($userName, "create user"))
        {
            return
        }

        $params = @{
            name       = $userName
            password   = $Credential.GetNetworkCredential().Password
            permission = $Permission
        }
        $bodyJson  = ConvertTo-Json -InputObject $params -Depth 5 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

        $uri = "$script:XoHost/rest/v0/users"
        $response = Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes

        if ($response -is [string] -and $response -match '\/rest\/v0\/users\/([0-9a-f-]+)')
        {
            Get-XoUser -UserId $matches[1]
        }
        elseif ($response -and $response.PSObject.Properties.Name -contains 'id')
        {
            Get-XoUser -UserId $response.id
        }
        else
        {
            $response
        }
    }
}

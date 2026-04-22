# SPDX-License-Identifier: Apache-2.0

function New-XoGroup
{
    <#
    .SYNOPSIS
        Create a new Xen Orchestra group.
    .DESCRIPTION
        Creates a new group via POST /groups. Groups are used to grant permissions to collections of users.
    .PARAMETER Name
        The name of the new group.
    .EXAMPLE
        New-XoGroup -Name "ops"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Group")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
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
        if (-not $PSCmdlet.ShouldProcess($Name, "create group"))
        {
            return
        }

        $params = @{ name = $Name }
        $bodyJson  = ConvertTo-Json -InputObject $params -Depth 3 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

        $uri = "$script:XoHost/rest/v0/groups"
        $response = Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes

        if ($response -is [string] -and $response -match '\/rest\/v0\/groups\/([0-9a-f-]+)')
        {
            Get-XoGroup -GroupId $matches[1]
        }
        elseif ($response -and $response.PSObject.Properties.Name -contains 'id')
        {
            Get-XoGroup -GroupId $response.id
        }
        else
        {
            $response
        }
    }
}

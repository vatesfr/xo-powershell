# SPDX-License-Identifier: Apache-2.0

$script:XO_DEFAULT_LIMIT = 25
$script:XoSessionLimit = $script:XO_DEFAULT_LIMIT

function Test-XoSession {
    <#
    .SYNOPSIS
        Check the connection to Xen Orchestra.
    .DESCRIPTION
        Tests if the current session is connected to a Xen Orchestra instance.
    .EXAMPLE
        Test-XoSession
        Returns $true if connected, $false otherwise.
    #>
    [CmdletBinding()]
    param()

    # Test connection by attempting to get tasks with a minimal limit
    try {
        Get-XoTask -Limit 1 | Out-Null
        Write-Verbose "Successful connection to Xen Orchestra - $script:XoHost"
        return $true
    }
    catch {
        Write-Error "Xen Orchestra connection error - $script:XoHost $_"
        return $false
    }
}

function Connect-XoSession {
    <#
    .SYNOPSIS
        Connect to a Xen Orchestra instance.
    .DESCRIPTION
        Establishes a connection to a Xen Orchestra instance using either token-based or credential-based authentication.
    .PARAMETER HostName
        The URL of the Xen Orchestra instance.
    .PARAMETER Credential
        Credentials for authentication (not currently implemented).
    .PARAMETER Token
        API token for authentication.
    .PARAMETER SaveCredentials
        Save credentials for future sessions.
    .PARAMETER SkipCertificateCheck
        Skips certificate validation (not recommended for production).
    .EXAMPLE
        Connect-XoSession -HostName "https://xo.example.com" -Token "your-api-token"
        Connects to the specified Xen Orchestra instance using a token.
    .EXAMPLE
        Connect-XoSession -HostName "https://xo.example.com"
        Prompts for a token and connects to the specified Xen Orchestra instance.
    #>
    [CmdletBinding(DefaultParameterSetName = "Token")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$HostName,

        [Parameter(Mandatory, ParameterSetName = "Credential")]
        [pscredential]$Credential,

        [Parameter(ParameterSetName = "Token")]
        [string]$Token,

        [Parameter()]
        [switch]$SaveCredentials,

        [Parameter()]
        [switch]$SkipCertificateCheck
    )

    $script:XoHost = $HostName.TrimEnd("/")
    Write-Verbose "Connecting to Xen Orchestra at $script:XoHost"

    # Reset session limit to default value on new connection
    $script:XoSessionLimit = $script:XO_DEFAULT_LIMIT

    $needsSave = $SaveCredentials

    if ($PSCmdlet.ParameterSetName -eq "Credential") {
        throw [System.NotImplementedException]::new("TODO: implement username/password login")
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Token" -and !$Token) {
        # TODO: load saved token
        if ($Token) {
            $needsSave = $false
        }
        else {
            $secureToken = Read-Host -AsSecureString -Prompt "Enter XO API token"
            $Token = [System.Net.NetworkCredential]::new("", $secureToken).Password
        }
    }

    $script:XoRestParameters = @{
        Headers = @{
            Cookie = "authenticationToken=$Token"
        }
    }

    if ($SkipCertificateCheck) {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            $script:XoRestParameters["SkipCertificateCheck"] = $true
        }
        else {
            Write-Warning "Certificate check skipping is only supported in PowerShell 6+. Using insecure handling method."
            if (-not ([System.Management.Automation.PSTypeName]'TrustAllCertsPolicy').Type) {
                Add-Type @"
                    using System.Net;
                    using System.Security.Cryptography.X509Certificates;
                    public class TrustAllCertsPolicy : ICertificatePolicy {
                        public bool CheckValidationResult(
                            ServicePoint srvPoint, X509Certificate certificate,
                            WebRequest request, int certificateProblem) {
                            return true;
                        }
                    }
"@
            }
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        }
    }

    # Save credentials if requested
    if ($needsSave) {
        # TODO: Implement credential saving
    }

    $connectionSuccessful = Test-XoSession

    if ($connectionSuccessful) {
        Write-Verbose "XoHost value: $script:XoHost"
        Write-Verbose "XoRestParameters: $($script:XoRestParameters.Headers | ConvertTo-Json -Compress)"
        return $true
    }
    else {
        Write-Error "Failed to connect to Xen Orchestra at $script:XoHost"
        $script:XoHost = $null
        $script:XoRestParameters = $null
        return $false
    }
}
New-Alias -Name Connect-XenOrchestra -Value Connect-XoSession

function Disconnect-XoSession {
    <#
    .SYNOPSIS
        Disconnect from a Xen Orchestra instance.
    .DESCRIPTION
        Disconnects from the current Xen Orchestra session and optionally clears saved credentials.
    .PARAMETER ClearCredentials
        Clears any saved credentials for the current session.
    .EXAMPLE
        Disconnect-XoSession
        Disconnects from the current session.
    .EXAMPLE
        Disconnect-XoSession -ClearCredentials
        Disconnects from the current session and clears saved credentials.
    #>
    [CmdletBinding()]
    param (
        [Parameter()][switch]$ClearCredentials
    )
    if ($ClearCredentials -and $script:XoHost) {
        # TODO: clear saved token
    }
    $script:XoHost = $null
    $script:XoRestParameters = $null
    $script:XoSessionLimit = $script:XO_DEFAULT_LIMIT
}
New-Alias -Name Disconnect-XenOrchestra -Value Disconnect-XoSession

function Get-XoSession {
    <#
    .SYNOPSIS
        Get the current XO session settings.
    .DESCRIPTION
        Get the current XO session settings.
    #>
    [CmdletBinding()]
    param()

    [pscustomobject]@{
        Limit = $script:XoSessionLimit
    }
}

function Set-XoSession {
    <#
    .SYNOPSIS
        Set the current XO session settings.
    .DESCRIPTION
        Set the current XO session settings.
    .PARAMETER Limit
        Sets the current XO query limit for all Get-Xo* cmdlets that support a -Limit parameter.
    .EXAMPLE
        Set-XoSession -Limit 50
        Sets the current session-wide limit to 50 items for all query cmdlets.
    .EXAMPLE
        Set-XoSession -Limit 0
        Sets cmdlets to return all items by default.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$Limit
    )

    if ($PSBoundParameters.ContainsKey("Limit")) {
        Write-Verbose "Default limit for XO queries changed from $script:XoSessionLimit to $Limit"
        $script:XoSessionLimit = $Limit
    }
}

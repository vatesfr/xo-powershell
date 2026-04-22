# SPDX-License-Identifier: Apache-2.0

function Connect-XoSession
{
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
    .PARAMETER Limit
        Default page size limit for query cmdlets.
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
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$HostName,

        [Parameter(Mandatory, ParameterSetName = "Credential")]
        [pscredential]$Credential,

        [Parameter(ParameterSetName = "Token")]
        [string]$Token,

        [Parameter()]
        [int]$Limit,

        [Parameter()]
        [switch]$SaveCredentials,

        [Parameter()]
        [switch]$SkipCertificateCheck
    )

    $script:XoHost = $HostName.TrimEnd("/")
    Write-Verbose "Connecting to Xen Orchestra at $script:XoHost"

    if ($PSBoundParameters.ContainsKey('Limit'))
    {
        $script:XoSessionLimit = $Limit
    }
    else
    {
        Write-Warning "No limit specified. Using default limit of $script:XO_DEFAULT_LIMIT. Use -Limit 0 for unlimited results."
        # Reset session limit to default value on new connection
        $script:XoSessionLimit = $script:XO_DEFAULT_LIMIT
    }

    $needsSave = $SaveCredentials

    if ($PSCmdlet.ParameterSetName -eq "Credential")
    {
        throw [System.NotImplementedException]::new("TODO: implement username/password login")
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Token" -and !$Token)
    {
        # TODO: load saved token
        if ($Token)
        {
            $needsSave = $false
        }
        else
        {
            $secureToken = Read-Host -AsSecureString -Prompt "Enter XO API token"
            $Token = [System.Net.NetworkCredential]::new("", $secureToken).Password
        }
    }

    $script:XoRestParameters = @{
        Headers = @{
            Cookie = "authenticationToken=$Token"
        }
    }

    if ($SkipCertificateCheck)
    {
        if ($PSVersionTable.PSVersion.Major -ge 6)
        {
            $script:XoRestParameters["SkipCertificateCheck"] = $true
        }
        else
        {
            Write-Warning "Certificate check skipping is only supported in PowerShell 6+. Using insecure handling method."
            if (-not ([System.Management.Automation.PSTypeName]'TrustAllCertsPolicy').Type)
            {
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
    if ($needsSave)
    {
        # TODO: Implement credential saving
    }

    $connectionSuccessful = Test-XoSession

    if ($connectionSuccessful)
    {
        Write-Verbose "XoHost value: $script:XoHost"
        Write-Verbose "XoRestParameters: $($script:XoRestParameters.Headers | ConvertTo-Json -Compress)"
        return $true
    }
    else
    {
        Write-Error "Failed to connect to Xen Orchestra at $script:XoHost"
        $script:XoHost = $null
        $script:XoRestParameters = $null
        return $false
    }
}
New-Alias -Name Connect-XenOrchestra -Value Connect-XoSession

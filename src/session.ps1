function Test-XoSession {
    <#
    .SYNOPSIS
        Check the connection to Xen Orchestra.
    #>
    [CmdletBinding()]
    param()

    # TODO: Do we have a test endpoint for Xo tokens?
    try {
        Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms" @script:XoRestParameters | Out-Null
        Write-Verbose "Successful connection to Xen Orchestra - $script:XoHost"
        return $true
    }
    catch {
        Write-Error "Xen Orchestra connection error - $script:XoHost $_"
        return $false
    }
}

# We end up using normal strings in the token anyway, but the main purpose of using PSCredential is to avoid saving/printing stuff in logs or console output
function Connect-XoSession {
    <#
    .SYNOPSIS
        Connect to a Xen Orchestra instance.
    #>
    [CmdletBinding(DefaultParameterSetName = "Token")]
    param (
        # Xen Orchestra URL to connect to.
        [Parameter(Mandatory)][string]$HostName,
        [Parameter(ParameterSetName = "Login")][pscredential]$Credential,
        [Parameter(ParameterSetName = "Login")][securestring]$Otp,
        [Parameter(ParameterSetName = "Login")][System.DateTimeOffset]$ExpiresAt,
        # Token to assign to session.
        [Parameter(ParameterSetName = "Token")]$Token,
        [Parameter()][switch]$SaveCredentials,
        # Insecure: skip certificate validation checks.
        [Parameter()][switch]$SkipCertificateCheck
    )

    $needsSave = $SaveCredentials

    if ($PSCmdlet.ParameterSetName -eq "Login") {
        throw [System.NotImplementedException]::new("TODO: implement username/password login")
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Token" -and !$Token) {
        # TODO: load saved token
        if ($Token) {
            $needsSave = $false
        }
        else {
            $Token = Read-Host -AsSecureString -Prompt "Enter token"
        }
    }

    if ($Token -is [securestring]) {
        $Token = ConvertFrom-XoSecureString $Token
    }
    $script:XoHost = $HostName
    $script:XoRestParameters = @{
        Headers              = @{
            Cookie = "authenticationToken=$Token"
        }
        SkipCertificateCheck = $SkipCertificateCheck
    }

    if ($needsSave) {
        # TODO: save token
    }

    try {
        Test-XoSession | Out-Null
    }
    catch {
        Disconnect-XenOrchestra
        throw
    }
}
New-Alias -Name Connect-XenOrchestra -Value Connect-XoSession

function Disconnect-XoSession {
    <#
    .SYNOPSIS
        Disconnect from a Xen Orchestra instance.
    #>
    [CmdletBinding()]
    param (
        # Clear saved tokens for the current session.
        [Parameter()][switch]$ClearCredentials
    )
    if ($ClearCredentials -and $script:XoHost) {
        # TODO: clear saved token
    }
    $script:XoHost = $null
    $script:XoRestParameters = $null
}
New-Alias -Name Disconnect-XenOrchestra -Value Disconnect-XoSession

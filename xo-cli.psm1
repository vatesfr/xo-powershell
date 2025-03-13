function Get-XenOrchestraCredentials {
    $credentialFile = "./xoa-credentials.json"
    if (Test-Path -Path $credentialFile) {
        $credentials = Get-Content -Path $credentialFile | ConvertFrom-Json
    if ($credentials.endpoint_url) {
        $global:XenOrchestraHost = $credentials.endpoint_url
        $global:ApiToken = $credentials.token
        $global:headers = @{
                Cookie = "authenticationToken=$global:ApiToken"
            }   
    }
    if (Test-XenOrchestraConnection) {
                    
        return
    }
    else {
        Write-Error "Wrong credentials, please check the JSON configuration file."
        }
    }
    while ($true) {
        # Request Xen Orchestra server URL
        $global:XenOrchestraHost = Read-Host -Prompt "Please enter the URL of the Xen Orchestra server (e.g. https://xen-orchestra-host)"

        # Request API token when loading module
        $global:ApiTokenSecure = Read-Host -Prompt "Please enter your API token" -AsSecureString

        # Convert SecureString to plain text
        $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:ApiTokenSecure)
        $global:ApiToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)  # Libérer la mémoire

        $global:headers = @{
            Cookie = "authenticationToken=$global:ApiToken"
    }

        # Test connection
        if (Test-XenOrchestraConnection) {
            break
        } else {
            Write-Warning "Connection failed. Please check the URL and API token."
        }
    }
}

# Check if a VmId is valid. It also avoid url manipulation with a malicious user entry 
function Check-VmID {
    param (
        [string]$VmId       
    )
    $VmsList = Invoke-RestMethod -Uri "$global:XenOrchestraHost/rest/v0/vms" -Method Get -Headers $global:headers -SkipCertificateCheck -ErrorAction Stop -TimeoutSec 30
    $IsValidVmId = $false
    foreach ($id in $VmsList) {
        if ($id -like "*/$VmId") {
            $IsValidVmId = $true
        break 
        }          
    }
    return $IsValidVmId
}

# Check if a VmId is valid. It also avoid url manipulation with a malicious user entry 
function Check-TaskID {
    param (
        [string]$TaskId       
    )
    $TaskList = Invoke-RestMethod -Uri "$global:XenOrchestraHost/rest/v0/tasks" -Method Get -Headers $global:headers -SkipCertificateCheck -ErrorAction Stop -TimeoutSec 30
    $IsValidVTaskId = $false
    foreach ($id in $TaskList) {
        if ($id -like "*/$TaskId") {
            $IsValidTaskId = $true
        break 
        }          
    }
    return $IsValidTaskId
}

# Function to check the connection to xoa 
function Test-XenOrchestraConnection {
    $testUri = "$global:XenOrchestraHost/rest/v0/vms"
    try {
        Invoke-RestMethod -Uri $testUri -Method Get -Headers $global:headers -SkipCertificateCheck -ErrorAction Stop -TimeoutSec 30
        Write-Output "Successful connection to XOA - $global:XenOrchestraHost"
        return $true
    } catch {
        Write-Error "XOA connection error - $global:XenOrchestraHost $_"
        return $false
    }
}

# Function to list all vms on the xoa cluster
function XoVms-List {
    param (
        [string]$Fields = "name_label,power_state"  # Default value for fields
    )

    $uri = "$global:XenOrchestraHost/rest/v0/vms?fields=$Fields"
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $global:headers -SkipCertificateCheck
    return $response
}

# Function to show details of a vms on the xoa cluster
function XoVms-Details {
    param (
        [string]$VmId
    )
    $IsValid = Check-VmID($VmId) 
    if (-not $IsValid) {
        Write-Error "Invalid VmID"
        return     
    }    
    $uri = "$global:XenOrchestraHost/rest/v0/vms/$VmId"
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $global:headers -SkipCertificateCheck
    return $response
}

# Function to start,restart,shutdown vms on the xoa cluster
function XoVms-Action {
    param (
        [string]$VmId,
        [ValidateSet("start", "clean_reboot", "hard_reboot", "clean_shutdown", "hard_shutdown")]
        [string]$Action
    )
    $IsValid = Check-VmID($VmId) 
    if (-not $IsValid) {
        Write-Error "Invalid VmID"
        return     
    }
    $uri = "$global:XenOrchestraHost/rest/v0/vms/$VmId/actions/$Action"
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $global:headers -SkipCertificateCheck
    return $response
}

# Function to take a snapshot of a vms on the xoa cluster
function XoVms-Snapshot {
    param (
        [string]$VmId
    )
    $IsValid = Check-VmID($VmId) 
    if (-not $IsValid) {
        Write-Error "Invalid VmID"
        return     
    }
    $uri = "$global:XenOrchestraHost/rest/v0/vms/$VmId/actions/snapshot"
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $global:headers -SkipCertificateCheck
    return $response
}

# Function to list all tasks on the xoa
function XoTasks-List {
    param (
        [string]$Fields = ""  # Default value for fields
    )

    # Build URL based on $Fields value
    if ([string]::IsNullOrEmpty($Fields)) {
        $uri = "$global:XenOrchestraHost/rest/v0/tasks"
    } else {
        $uri = "$global:XenOrchestraHost/rest/v0/tasks?filter=$Fields"
    }

    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $global:headers -SkipCertificateCheck
    return $response
}

# Function to show details of a tasks on the xoa
function XoTasks-Details {
    param (
        [string]$TaskId  # Default value for fields
    )
        $IsValid = Check-TaskID($TaskId) 
    if (-not $IsValid) {
        Write-Error "Invalid TaskID"
        return     
    }
    $uri = "$global:XenOrchestraHost/rest/v0/tasks/$TaskId"
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $global:headers -SkipCertificateCheck
    return $response
}

# Get startup credentials
Get-XenOrchestraCredentials
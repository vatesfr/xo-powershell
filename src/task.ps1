# Function to list all tasks on the xoa
function XoTasks-List {
    param (
        [string]$Fields = ""  # Default value for fields
    )

    # Build URL based on $Fields value
    if ([string]::IsNullOrEmpty($Fields)) {
        $uri = "$script:XenOrchestraHost/rest/v0/tasks"
    }
    else {
        $uri = "$script:XenOrchestraHost/rest/v0/tasks?filter=$Fields"
    }

    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $script:headers -SkipCertificateCheck
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
    $uri = "$script:XenOrchestraHost/rest/v0/tasks/$TaskId"
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $script:headers -SkipCertificateCheck
    return $response
}

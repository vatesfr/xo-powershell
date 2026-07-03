# SPDX-License-Identifier: Apache-2.0

# Internal: resource type to REST endpoint
$script:XO_TAG_ENDPOINTS = @{
    Vm   = "vms"
    Host = "hosts"
    Sr   = "srs"
}

function Get-XoCurrentTags {
    param([string]$Endpoint, [string]$Uuid)
    $result = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/$Endpoint/$Uuid" @script:XoRestParameters -Body @{ fields = "uuid,tags" }
    if ($null -eq $result.tags) { return @() }
    return @($result.tags)
}

function Invoke-XoTagPatch {
    param([string]$Endpoint, [string]$Uuid, [string[]]$Tags)
    $body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json @{ tags = @($Tags) }))
    Invoke-RestMethod -Uri "$script:XoHost/rest/v0/$Endpoint/$Uuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
}

function Add-XoTag {
    <#
    .SYNOPSIS
        Add one or more tags to a VM, Host, or SR.
    .DESCRIPTION
        Adds the specified tag(s) to the resource without removing existing tags.
        Accepts pipeline input from Get-XoVm, Get-XoHost, and Get-XoSr.
    .PARAMETER VmUuid
        UUID of the VM to tag.
    .PARAMETER HostUuid
        UUID of the Host to tag.
    .PARAMETER SrUuid
        UUID of the SR to tag.
    .PARAMETER Tag
        One or more tag strings to add.
    .EXAMPLE
        Add-XoTag -VmUuid "12345678-abcd-1234-abcd-1234567890ab" -Tag "Production"
        Adds the "Production" tag to the specified VM.
    .EXAMPLE
        Get-XoVm -PowerState Running | Add-XoTag -Tag "Running","Prod"
        Adds two tags to all running VMs.
    .EXAMPLE
        Get-XoSr | Add-XoTag -Tag "Reviewed-2026"
        Adds a tag to all storage repositories.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = "Vm")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Vm")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VmUuid,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Host")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$HostUuid,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Sr")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$SrUuid,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tag
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }
        $endpoint = $script:XO_TAG_ENDPOINTS[$PSCmdlet.ParameterSetName]
    }

    process {
        $uuids = switch ($PSCmdlet.ParameterSetName) {
            "Vm"   { $VmUuid }
            "Host" { $HostUuid }
            "Sr"   { $SrUuid }
        }

        foreach ($uuid in $uuids) {
            if ($PSCmdlet.ShouldProcess($uuid, "add tag(s): $($Tag -join ', ')")) {
                $current = Get-XoCurrentTags -Endpoint $endpoint -Uuid $uuid
                $merged  = @($current) + @($Tag) | Select-Object -Unique
                Invoke-XoTagPatch -Endpoint $endpoint -Uuid $uuid -Tags $merged
                Write-Verbose "[$uuid] Tags now: $($merged -join ', ')"
            }
        }
    }
}

function Remove-XoTag {
    <#
    .SYNOPSIS
        Remove one or more tags from a VM, Host, or SR - or from every resource that has them.
    .DESCRIPTION
        Removes only the specified tag(s). All other tags on the resource are preserved.
        Accepts pipeline input from Get-XoVm, Get-XoHost, and Get-XoSr.
        With -All, skips explicit UUIDs entirely and scans all resources of the given
        type(s), stripping the tag(s) from every one that carries them - useful for
        retiring a deprecated tag environment-wide.
    .PARAMETER VmUuid
        UUID of the VM.
    .PARAMETER HostUuid
        UUID of the Host.
    .PARAMETER SrUuid
        UUID of the SR.
    .PARAMETER All
        Scan all resources of the specified -ResourceType(s) and remove the tag(s) from
        every one that has them, instead of targeting specific UUIDs.
    .PARAMETER ResourceType
        With -All, which resource types to scan. Defaults to all (Vm, Host, Sr).
    .PARAMETER Tag
        One or more tag strings to remove.
    .EXAMPLE
        Remove-XoTag -VmUuid "12345678-abcd-1234-abcd-1234567890ab" -Tag "OldTag"
        Removes "OldTag" from the specified VM.
    .EXAMPLE
        Get-XoVm -Tag "Decommissioned" | Remove-XoTag -Tag "Decommissioned"
        Removes the "Decommissioned" tag from every VM that carries it.
    .EXAMPLE
        Remove-XoTag -Tag "Decommissioned" -All -WhatIf
        Shows every VM, Host, and SR that would have "Decommissioned" removed.
    .EXAMPLE
        Remove-XoTag -Tag "Decommissioned" -All -ResourceType Vm
        Removes "Decommissioned" from every VM that carries it, without needing UUIDs.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium", DefaultParameterSetName = "Vm")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Vm")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VmUuid,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Host")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$HostUuid,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Sr")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$SrUuid,

        [Parameter(Mandatory, ParameterSetName = "All")]
        [switch]$All,

        [Parameter(ParameterSetName = "All")]
        [ValidateSet("Vm", "Host", "Sr")]
        [string[]]$ResourceType = @("Vm", "Host", "Sr"),

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tag
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }
        if ($PSCmdlet.ParameterSetName -ne "All") {
            $endpoint = $script:XO_TAG_ENDPOINTS[$PSCmdlet.ParameterSetName]
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "All") { return }

        $uuids = switch ($PSCmdlet.ParameterSetName) {
            "Vm"   { $VmUuid }
            "Host" { $HostUuid }
            "Sr"   { $SrUuid }
        }

        foreach ($uuid in $uuids) {
            if ($PSCmdlet.ShouldProcess($uuid, "remove tag(s): $($Tag -join ', ')")) {
                $current = Get-XoCurrentTags -Endpoint $endpoint -Uuid $uuid
                $updated = $current | Where-Object { $_ -notin $Tag }

                if ($current.Count -eq $updated.Count) {
                    Write-Warning "[$uuid] None of the specified tags were present. No change made."
                    continue
                }

                Invoke-XoTagPatch -Endpoint $endpoint -Uuid $uuid -Tags $updated
                Write-Verbose "[$uuid] Tags now: $($updated -join ', ')"
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -ne "All") { return }

        foreach ($type in $ResourceType) {
            $typeEndpoint = $script:XO_TAG_ENDPOINTS[$type]

            try {
                $response = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/$typeEndpoint" @script:XoRestParameters -Body @{ fields = "uuid,tags" }

                foreach ($item in $response) {
                    if ($null -eq $item.tags) { continue }

                    $current = @($item.tags)
                    $updated = $current | Where-Object { $_ -notin $Tag }

                    if ($current.Count -eq $updated.Count) { continue }

                    if ($PSCmdlet.ShouldProcess($item.uuid, "remove tag(s): $($Tag -join ', ')")) {
                        Invoke-XoTagPatch -Endpoint $typeEndpoint -Uuid $item.uuid -Tags $updated
                        Write-Verbose "[$($item.uuid)] Tags now: $($updated -join ', ')"
                    }
                }
            }
            catch {
                Write-Warning "Failed to query $type resources: $_"
            }
        }
    }
}

function Rename-XoTag {
    <#
    .SYNOPSIS
        Rename a tag across all VMs, Hosts, and SRs that carry it.
    .DESCRIPTION
        Finds every resource of the specified type(s) tagged with -OldName and replaces
        that tag with -NewName, preserving all other tags on the resource. If a resource
        already has -NewName as well as -OldName, the duplicate is dropped rather than
        producing two identical tags.
    .PARAMETER OldName
        The existing tag name to replace.
    .PARAMETER NewName
        The new tag name.
    .PARAMETER ResourceType
        Which resource types to scan. Defaults to all (Vm, Host, Sr).
    .EXAMPLE
        Rename-XoTag -OldName "prod" -NewName "Production"
        Renames "prod" to "Production" on every VM, Host, and SR that has it.
    .EXAMPLE
        Rename-XoTag -OldName "prod" -NewName "Production" -ResourceType Vm -WhatIf
        Shows which VMs would be affected without making any change.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OldName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$NewName,

        [Parameter()]
        [ValidateSet("Vm", "Host", "Sr")]
        [string[]]$ResourceType = @("Vm", "Host", "Sr")
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }
    }

    end {
        if ($OldName -eq $NewName) {
            Write-Warning "OldName and NewName are identical ('$OldName'). Nothing to do."
            return
        }

        foreach ($type in $ResourceType) {
            $endpoint = $script:XO_TAG_ENDPOINTS[$type]

            try {
                $params = @{
                    fields = "uuid,tags"
                    filter = "tags:($OldName)"
                }
                $response = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/$endpoint" @script:XoRestParameters -Body $params

                foreach ($item in $response) {
                    if ($PSCmdlet.ShouldProcess($item.uuid, "rename tag '$OldName' to '$NewName'")) {
                        $updated = @($item.tags) | ForEach-Object { if ($_ -eq $OldName) { $NewName } else { $_ } } | Select-Object -Unique
                        Invoke-XoTagPatch -Endpoint $endpoint -Uuid $item.uuid -Tags $updated
                        Write-Verbose "[$($item.uuid)] Tags now: $($updated -join ', ')"
                    }
                }
            }
            catch {
                Write-Warning "Failed to query $type resources: $_"
            }
        }
    }
}

function Get-XoUntagged {
    <#
    .SYNOPSIS
        List VMs, Hosts, and SRs that have no tags at all.
    .DESCRIPTION
        Scans all resources of the specified type(s) and returns the ones with an empty
        or missing tags list. Useful for finding resources that haven't been tagged yet
        as part of a tagging/governance sweep.
    .PARAMETER ResourceType
        Which resource types to scan. Defaults to all (Vm, Host, Sr).
    .EXAMPLE
        Get-XoUntagged
        Lists every VM, Host, and SR that currently has no tags.
    .EXAMPLE
        Get-XoUntagged -ResourceType Vm
        Lists only untagged VMs.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet("Vm", "Host", "Sr")]
        [string[]]$ResourceType = @("Vm", "Host", "Sr")
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }
    }

    end {
        foreach ($type in $ResourceType) {
            $endpoint = $script:XO_TAG_ENDPOINTS[$type]

            try {
                $response = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/$endpoint" @script:XoRestParameters -Body @{ fields = "uuid,name_label,tags" }

                foreach ($item in $response) {
                    if ($null -eq $item.tags -or @($item.tags).Count -eq 0) {
                        [PSCustomObject]@{
                            ResourceType = $type
                            Uuid         = $item.uuid
                            Name         = $item.name_label
                        }
                    }
                }
            }
            catch {
                Write-Warning "Failed to query $type resources: $_"
            }
        }
    }
}

function Get-XoTag {
    <#
    .SYNOPSIS
        List all tags in use across VMs, Hosts, and SRs, or drill down into a specific tag.
    .DESCRIPTION
        Without -Tag, scans all resources of the specified type(s) and returns every tag
        currently in use with a count of how many resources carry it. Results are sorted by count.
        With -Tag, instead returns the actual resources (VM/Host/SR) that carry that tag.
    .PARAMETER ResourceType
        Which resource types to scan. Defaults to all (Vm, Host, Sr).
    .PARAMETER Tag
        Drill down: return the resources carrying this tag instead of the aggregate tag list.
    .EXAMPLE
        Get-XoTag
        Lists all tags across VMs, Hosts, and SRs with usage counts.
    .EXAMPLE
        Get-XoTag -ResourceType Vm
        Lists tags used on VMs only.
    .EXAMPLE
        Get-XoTag -Tag "Production"
        Lists every VM, Host, and SR tagged "Production".
    .EXAMPLE
        Get-XoTag -Tag "Production" -ResourceType Vm
        Lists only VMs tagged "Production".
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet("Vm", "Host", "Sr")]
        [string[]]$ResourceType = @("Vm", "Host", "Sr"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Tag
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }
    }

    end {
        if ($PSBoundParameters.ContainsKey("Tag")) {
            foreach ($type in $ResourceType) {
                $endpoint = $script:XO_TAG_ENDPOINTS[$type]

                try {
                    $params = @{
                        fields = "uuid,name_label,tags"
                        filter = "tags:($Tag)"
                    }
                    $response = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/$endpoint" @script:XoRestParameters -Body $params

                    foreach ($item in $response) {
                        [PSCustomObject]@{
                            ResourceType = $type
                            Uuid         = $item.uuid
                            Name         = $item.name_label
                            Tags         = @($item.tags)
                        }
                    }
                }
                catch {
                    Write-Warning "Failed to query $type resources: $_"
                }
            }
            return
        }

        $tagCounts = @{}

        foreach ($type in $ResourceType) {
            $endpoint = $script:XO_TAG_ENDPOINTS[$type]

            try {
                $response = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/$endpoint" @script:XoRestParameters -Body @{ fields = "uuid,tags" }

                foreach ($item in $response) {
                    if ($null -eq $item.tags) { continue }
                    foreach ($t in $item.tags) {
                        if ([string]::IsNullOrWhiteSpace($t)) { continue }
                        if ($tagCounts.ContainsKey($t)) { $tagCounts[$t]++ } else { $tagCounts[$t] = 1 }
                    }
                }
            }
            catch {
                Write-Warning "Failed to query $type resources: $_"
            }
        }

        $tagCounts.GetEnumerator() |
            Sort-Object -Property Value -Descending |
            ForEach-Object {
                [PSCustomObject]@{
                    Tag   = $_.Key
                    Count = $_.Value
                }
            }
    }
}

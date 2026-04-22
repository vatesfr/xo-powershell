# SPDX-License-Identifier: Apache-2.0

# For convenience. Internal use only.
function Invoke-XoPoolAction
{
    <#
    .SYNOPSIS
    Internal function used to manage Xen Orchestra pool actions

    .DESCRIPTION
    Internal function used to manage Xen Orchestra pool actions

    .PARAMETER PoolUuid
    Target Xen Orchestra Pool Id

    .PARAMETER Action
    Target Xen Orchestra Pool action

    .PARAMETER Sync
    Force the Xen Orchestra pool to sync

    .PARAMETER ActionParameters
    A hashtable with the required parameters for each action

    .EXAMPLE
    Invoke-XoPoolAction -PoolUuid $id -Action "rolling_reboot"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$PoolUuid,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet(
            "create_bonded_network",
            "create_internal_network",
            "create_network",
            "create_vm",
            "emergency_shutdown",
            "management_reconfigure",
            "rolling_reboot",
            "rolling_update"
        )]
        [string]$Action,

        [Parameter()]
        [switch]$Sync,

        [Parameter()]
        [hashtable]$ActionParameters
    )

    process
    {
        switch ($Action)
        {
            "create_bonded_network"
            {

                if (-not ($PSBoundParameters.ContainsKey("ActionParameters")))
                {
                    throw "ActionParameters are required. For all available parameters, check the docs '/rest/v0/docs/#/pools/CreateBondedNetwork'"
                }
            }
            "create_internal_network"
            {

                if (-not ($PSBoundParameters.ContainsKey("ActionParameters")))
                {
                    throw "ActionParameters are required. For all available parameters, check the docs '/rest/v0/docs/#/pools/CreateInternalNetwork'"
                }
            }
            "create_network"
            {

                if (-not ($PSBoundParameters.ContainsKey("ActionParameters")))
                {
                    throw "ActionParameters are required. For all available parameters, check the docs '/rest/v0/docs/#/pools/CreateNetwork'"
                }
            }
            "create_vm"
            {

                if (-not ($PSBoundParameters.ContainsKey("ActionParameters")))
                {
                    throw "ActionParameters are required. For all available parameters, check the docs '/rest/v0/docs/#/pools/CreateVm'"
                }
            }
            "emergency_shutdown"
            {

                $ActionParameters = @{}
            }
            "management_reconfigure"
            {

                if (-not ($PSBoundParameters.ContainsKey("ActionParameters")))
                {
                    throw "ActionParameters are required. For all available parameters, check the docs '/rest/v0/docs/#/pools/ManagementReconfigure'"
                }
            }
            "rolling_reboot"
            {

                $ActionParameters = @{}
            }
            "rolling_update"
            {

                $ActionParameters = @{}
            }
        }

        foreach ($id in $PoolUuid)
        {
            $bodyJson = ConvertTo-Json -InputObject $ActionParameters -Depth 99 -Compress
            $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)
            Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$id/actions/${Action}?sync=$($Sync.IsPresent.ToString().ToLower())" -Method Post @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes | ForEach-Object {
                # XO pool actions return one of:
                #   1. a task href string (e.g. "/rest/v0/tasks/0m8k2zkzi") - async
                #   2. a task id string (e.g. "0m8k2zkzi")
                #   3. a PSObject with an "id" field (JSON body response)
                # Normalise all three to an XoPowershell.Task by resolving through Get-XoTask.
                if ($_ -is [string])
                {
                    if ($_ -match '\/rest\/v0\/tasks\/([0-9a-z]+)')
                    {
                        ConvertFrom-XoTaskHref $_
                    }
                    else
                    {
                        Get-XoTask -TaskId $_
                    }
                }
                elseif ($_ -and $_.PSObject.Properties.Name -contains 'id')
                {
                    Get-XoTask -TaskId $_.id
                }
                else
                {
                    $_
                }
            }
        }
    }
}

# SPDX-License-Identifier: Apache-2.0

function Set-XoObject
{
    <#
    .SYNOPSIS
    Set Xo Object with custom type

    .DESCRIPTION
    Sets an object's PSTypeName and adds custom properties.

    .PARAMETER InputObject
    Target object to decorate with properties.

    .PARAMETER TypeName
    Custom PSTypeName for the object.

    .PARAMETER Properties
    Properties to add to the target object.

    .EXAMPLE
    Set-XoObject $InputObject -TypeName XoPowershell.MyCustomType -Properties $props
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'low')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject,
        [Parameter()][string]$TypeName,
        [Parameter()][hashtable]$Properties
    )
    process
    {
        if ($PSCmdlet.ShouldProcess($TypeName, "Setting object "))
        {

            if ($TypeName)
            {
                $InputObject.PSObject.TypeNames.Insert(0, $TypeName) > $null
            }
            if ($Properties)
            {
                foreach ($key in $Properties.Keys)
                {
                    $InputObject.PSObject.Properties.Add([psnoteproperty]::new($key, $Properties[$key])) > $null
                }
            }
            [PSCustomObject]$InputObject
        }
    }
}

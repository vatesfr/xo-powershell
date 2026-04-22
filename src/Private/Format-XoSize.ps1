# SPDX-License-Identifier: Apache-2.0

function Format-XoSize
{
    <#
    .SYNOPSIS
    Converts size into a readable format

    .DESCRIPTION
    Converts a byte size into a human-readable format.

    .PARAMETER Value
    Target size in bytes to format.

    .EXAMPLE
    291843908213409 | Format-XoSize
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [long]$Value
    )
    process
    {
        # based off of https://stackoverflow.com/a/40887001/8642889

        $suffix = " B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
        $index = 0
        while ($Value -gt 1kb -and $index -lt $suffix.Length)
        {
            $Value = $Value / 1kb
            $index++
        }

        "{0:N1} {1}" -f $Value, $suffix[$index]
    }
}

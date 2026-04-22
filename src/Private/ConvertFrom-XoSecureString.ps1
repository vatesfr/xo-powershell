# SPDX-License-Identifier: Apache-2.0

function ConvertFrom-XoSecureString
{
    <#
    .SYNOPSIS
    Convert secure string into string

    .DESCRIPTION
    Convert a SecureString to a plain string value.

    .PARAMETER SecureString
    SecureString to convert to plain text.

    .EXAMPLE
    ConvertFrom-XoSecureString -SecureString 'MySecretString'
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [securestring]$SecureString
    )

    process
    {
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        try
        {
            return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        }
        finally
        {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

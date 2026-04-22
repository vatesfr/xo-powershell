function ConvertFrom-XoTaskHref
{
    <#
    .SYNOPSIS
        Convert a task URL to a task object
    .DESCRIPTION
        Extracts the task ID from a URL and retrieves the task from the API
    .PARAMETER Uri
        The task href URL to convert to an object.
    .EXAMPLE
        ConvertFrom-XoTaskHref -Uri $uri
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string]$Uri
    )

    process
    {
        if ($Uri -imatch "\/rest\/v0\/tasks\/([0-9a-z]+)")
        {
            $taskId = $matches[1]
        }
        elseif ($Uri -imatch "^@\{taskId=.*\}")
        {
            $data = ConvertFrom-StringData -StringData "$($Uri -replace '(@|\{|\})','')"
            $taskId = ([pscustomobject]$data).taskId
        }
        else
        {
            throw "Bad task href format: {0}", $Uri
        }


        Get-XoTask -TaskId $taskId
    }
}

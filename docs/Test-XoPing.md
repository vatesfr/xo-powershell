---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Test-XoPing

## SYNOPSIS
Test the reachability of the Xen Orchestra REST API.

## SYNTAX

```
Test-XoPing [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends a GET to the /ping endpoint using the current session credentials.
Returns $true on success (2xx) or $false on any failure (network error, auth error, non-2xx).
Does not throw.
Useful for quick health probes in monitoring scripts.

## EXAMPLES

### EXAMPLE 1
```
if (-not (Test-XoPing)) { throw "XO API unreachable" }
```

## PARAMETERS

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES

## RELATED LINKS

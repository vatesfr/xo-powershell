---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Test-XoSession

## SYNOPSIS
Check the connection to Xen Orchestra.

## SYNTAX

```
Test-XoSession [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Tests if the current session is connected to a Xen Orchestra instance.

## EXAMPLES

### EXAMPLE 1
```
Test-XoSession
Returns $true if connected, $false otherwise.
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

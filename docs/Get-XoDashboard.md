---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoDashboard

## SYNOPSIS
Get the Xen Orchestra global dashboard summary.

## SYNTAX

```
Get-XoDashboard [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the global dashboard object exposed at /dashboard: aggregate counters (nHosts, nPools), resource overview (cpus, memory, storage), pool connectivity status, and repository totals.
Useful for a one-shot health snapshot of the XO deployment.

## EXAMPLES

### EXAMPLE 1
```
Get-XoDashboard
```

### EXAMPLE 2
```
(Get-XoDashboard).resourcesOverview
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

### XoPowershell.Dashboard
## NOTES

## RELATED LINKS

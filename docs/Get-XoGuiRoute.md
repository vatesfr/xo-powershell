---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoGuiRoute

## SYNOPSIS
Get the Xen Orchestra GUI route table.

## SYNTAX

```
Get-XoGuiRoute [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the /gui-routes resource which maps GUI generation names (e.g.
xo5, xo6) to their URL prefixes.
This is mainly useful for tooling that needs to construct GUI deep links.

## EXAMPLES

### EXAMPLE 1
```
Get-XoGuiRoute
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

### XoPowershell.GuiRoute
## NOTES

## RELATED LINKS

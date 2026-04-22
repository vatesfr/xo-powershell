---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoVmDashboard

## SYNOPSIS
Get dashboard summary scoped to a specific VM.

## SYNTAX

```
Get-XoVmDashboard [-VmUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves dashboard summary attached to the specified Xen Orchestra VM.
Accepts one or more VM UUIDs; each is queried independently and the combined results are returned.

## EXAMPLES

### EXAMPLE 1
```
Get-XoVmDashboard -VmUuid "613f541c-4bed-fc77-7ca8-2db6b68f079c"
```

### EXAMPLE 2
```
Get-XoVm | Get-XoVmDashboard
```

## PARAMETERS

### -VmUuid
The UUID(s) of the VM whose dashboard summary should be returned.
Accepts pipeline input by property name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

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

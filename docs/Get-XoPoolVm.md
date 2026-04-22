---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoPoolVm

## SYNOPSIS
Get VMs scoped to a specific pool.

## SYNTAX

```
Get-XoPoolVm [-PoolUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns the VMs that belong to the specified pool(s).
The XO REST API does not expose a dedicated GET /pools/{id}/vms endpoint (only POST for imports), so this cmdlet delegates to Get-XoVm with a $pool filter.
Accepts one or more pool UUIDs and pipeline input by property name.

## EXAMPLES

### EXAMPLE 1
```
Get-XoPoolVm -PoolUuid "b7569d99-30f8-178a-7d94-801de3e29b5b"
```

### EXAMPLE 2
```
Get-XoPool | Get-XoPoolVm
```

## PARAMETERS

### -PoolUuid
The UUID(s) of the pool whose VMs should be returned.
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

### XoPowershell.Vm
## NOTES

## RELATED LINKS

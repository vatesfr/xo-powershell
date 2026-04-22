---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoSingleVdiSnapshotById

## SYNOPSIS
Get a VDI Snapshot by ID

## SYNTAX

```
Get-XoSingleVdiSnapshotById [[-VdiSnapshotUuid] <String>] [[-Params] <Hashtable>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get a single VDI Snapshot from Xen Orchestra by UUID.

## EXAMPLES

### EXAMPLE 1
```
Get-XoSingleVdiSnapshotById -VdiSnapshotUuid '812b59e1-2682-43ef-acd4-808d3551b907'
```

## PARAMETERS

### -VdiSnapshotUuid
Target VDI Snapshot UUID to retrieve.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Params
Target VDI Snapshot request parameters hash.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
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

### XoPowershell.VdiSnapshot
## NOTES

## RELATED LINKS

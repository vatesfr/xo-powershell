---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoVdiSnapshot

## SYNOPSIS
Get VDI snapshots from Xen Orchestra.

## SYNTAX

### Filter (Default)
```
Get-XoVdiSnapshot [-Filter <String>] [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### VdiSnapshotUuid
```
Get-XoVdiSnapshot [-VdiSnapshotUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves VDI snapshots from Xen Orchestra.
Can retrieve specific snapshots by their UUID
or filter snapshots by various criteria.

## EXAMPLES

### EXAMPLE 1
```
Get-XoVdiSnapshot
Returns up to 25 VDI snapshots.
```

### EXAMPLE 2
```
Get-XoVdiSnapshot -Limit 0
Returns all VDI snapshots without limit.
```

### EXAMPLE 3
```
Get-XoVdiSnapshot -VdiSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab"
Returns the VDI snapshot with the specified UUID.
```

### EXAMPLE 4
```
Get-XoVdiSnapshot -Filter "name_label:backup*"
Returns VDI snapshots with names starting with "backup" (up to default limit).
```

## PARAMETERS

### -VdiSnapshotUuid
The UUID(s) of the VDI snapshot(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: VdiSnapshotUuid
Aliases: VdiSnapshotId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Filter
Filter to apply to the snapshot query.

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Maximum number of results to return.
Default is 25 if not specified.

```yaml
Type: Int32
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: $script:XoSessionLimit
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

## NOTES

## RELATED LINKS

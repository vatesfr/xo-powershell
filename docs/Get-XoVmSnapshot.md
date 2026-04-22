---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoVmSnapshot

## SYNOPSIS
Get VM snapshots.

## SYNTAX

### Filter (Default)
```
Get-XoVmSnapshot [-Filter <String>] [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### VmSnapshotUuid
```
Get-XoVmSnapshot [-VmSnapshotUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves VM snapshots from Xen Orchestra.
Can retrieve specific snapshots by their UUID
or filter snapshots by various criteria.

## EXAMPLES

### EXAMPLE 1
```
Get-XoVmSnapshot
Returns up to 25 VM snapshots.
```

### EXAMPLE 2
```
Get-XoVmSnapshot -Limit 0
Returns all VM snapshots without limit.
```

### EXAMPLE 3
```
Get-XoVmSnapshot -VmSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab"
Returns the VM snapshot with the specified UUID.
```

### EXAMPLE 4
```
Get-XoVmSnapshot -Filter "name_label:backup"
Returns VM snapshots with "backup" in their name (up to default limit).
```

## PARAMETERS

### -VmSnapshotUuid
The UUID(s) of the VM snapshot(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: VmSnapshotUuid
Aliases: Snapshot

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

### XoPowershell.VmSnapshot
## NOTES

## RELATED LINKS

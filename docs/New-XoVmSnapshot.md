---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# New-XoVmSnapshot

## SYNOPSIS
Create a snapshot of one or more VMs.

## SYNTAX

```
New-XoVmSnapshot [-VmUuid] <String[]> [[-SnapshotName] <String>] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a snapshot of the specified VMs.
Optionally, you can specify a custom name
for the snapshot.

## EXAMPLES

### EXAMPLE 1
```
New-XoVmSnapshot -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
Creates a snapshot of the VM with the specified UUID.
```

### EXAMPLE 2
```
New-XoVmSnapshot -VmUuid "12345678-abcd-1234-abcd-1234567890ab" -SnapshotName "Before Update"
Creates a snapshot named "Before Update" of the VM with the specified UUID.
```

### EXAMPLE 3
```
New-XoVmSnapshot -VmUuid "12345678-abcd-1234-abcd-1234567890ab" -NameLabel "Before Update"
Creates a snapshot named "Before Update" of the VM with the specified UUID.
```

### EXAMPLE 4
```
Get-XoVm -PowerState Running | New-XoVmSnapshot -SnapshotName "Backup $(Get-Date -Format 'yyyy-MM-dd')"
Creates a dated snapshot of all running VMs.
```

## PARAMETERS

### -VmUuid
The UUID(s) of the VM(s) to snapshot.

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

### -SnapshotName
The name to give to the snapshot.
If not specified, a default name will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases: NameLabel

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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

## NOTES

## RELATED LINKS

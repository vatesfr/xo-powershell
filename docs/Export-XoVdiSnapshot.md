---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Export-XoVdiSnapshot

## SYNOPSIS
Export a VDI snapshot.

## SYNTAX

```
Export-XoVdiSnapshot [-VdiSnapshotUuid] <String> [-Format] <String> [-OutFile] <String> [-PassThru]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Export a VDI snapshot from Xen Orchestra.
Downloads the snapshot to a local file.

## EXAMPLES

### EXAMPLE 1
```
Export-XoVdiSnapshot -VdiSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab" -Format vhd -OutFile "C:\Exports\snapshot.vhd"
Exports the VDI snapshot in VHD format to the specified file.
```

### EXAMPLE 2
```
Get-XoVdiSnapshot -VdiSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab" | Export-XoVdiSnapshot -Format vhd -OutFile "C:\Exports\snapshot.vhd"
Exports the VDI snapshot in VHD format to the specified file, piping from Get-XoVdiSnapshot.
```

## PARAMETERS

### -VdiSnapshotUuid
The UUID of the VDI snapshot to export.

```yaml
Type: String
Parameter Sets: (All)
Aliases: VdiSnapshotId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Format
The format to export the VDI snapshot in.
Valid values: raw, vhd.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile
The path to save the exported VDI snapshot to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
If specified, returns the exported file info as a FileInfo object.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

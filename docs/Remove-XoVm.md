---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Remove-XoVm

## SYNOPSIS
Delete one or more Xen Orchestra VMs.

## SYNTAX

```
Remove-XoVm [-VmUuid] <String[]> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Issues DELETE /vms/{id}.
The VM must be shut down before it can be deleted.
Associated VDIs are destroyed along with the VM unless detached first.
Accepts multiple UUIDs and pipeline input by property name.

## EXAMPLES

### EXAMPLE 1
```
Remove-XoVm -VmUuid "613f541c-4bed-fc77-7ca8-2db6b68f079c"
```

### EXAMPLE 2
```
Get-XoVm -PowerState Halted | Where-Object Name -like 'tmp-*' | Remove-XoVm
```

## PARAMETERS

### -VmUuid
The UUID(s) of the VM(s) to delete.

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

---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoVmVdi

## SYNOPSIS
Get virtual disks attached to a VM.

## SYNTAX

```
Get-XoVmVdi [-VmUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves all virtual disk images (VDIs) attached to a specified VM.

## EXAMPLES

### EXAMPLE 1
```
Get-XoVmVdi -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
Returns all virtual disks attached to the specified VM.
```

### EXAMPLE 2
```
Get-XoVm -PowerState Running | Get-XoVmVdi
Returns all virtual disks attached to running VMs.
```

## PARAMETERS

### -VmUuid
The UUID of the VM to get VDIs for.

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

## NOTES

## RELATED LINKS

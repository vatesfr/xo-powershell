---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoVmTemplate

## SYNOPSIS
List or query VM templates.

## SYNTAX

### Filter (Default)
```
Get-XoVmTemplate [-Default] [-PoolUuid <String>] [-Filter <String>] [-Limit <Int32>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### VmTemplateUuid
```
Get-XoVmTemplate [-VmTemplateUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get Xen Orchestra VM templates by UUID or list all existing VM templates.

## EXAMPLES

### EXAMPLE 1
```
Get-XoVmTemplate -VmTemplateUuid "12345678-abcd-1234-abcd-1234567890ab"
```

## PARAMETERS

### -VmTemplateUuid
The UUID(s) of the VM template(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: VmTemplateUuid
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Default
Only return default VM templates when set.

```yaml
Type: SwitchParameter
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PoolUuid
UUID of the pool whose templates to retrieve.

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Filter
Custom filter expression for the template query.

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
Maximum number of VM templates to return.

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

### XoPowershell.VmTemplate
## NOTES

## RELATED LINKS

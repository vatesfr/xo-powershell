---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoVmTemplateAlarm

## SYNOPSIS
Get alarms scoped to a specific VM template.

## SYNTAX

```
Get-XoVmTemplateAlarm [-VmTemplateUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves alarms attached to the specified Xen Orchestra VM template.
Accepts one or more VM template UUIDs; each is queried independently and the combined results are returned.

## EXAMPLES

### EXAMPLE 1
```
Get-XoVmTemplateAlarm -VmTemplateUuid "00000000-0000-0000-0000-000000000000"
```

### EXAMPLE 2
```
Get-XoVmTemplate | Get-XoVmTemplateAlarm
```

## PARAMETERS

### -VmTemplateUuid
The UUID(s) of the VM template whose alarms should be returned.
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

### XoPowershell.Alarm
## NOTES

## RELATED LINKS

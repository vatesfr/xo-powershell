---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoVbd

## SYNOPSIS
Query VBDs by UUID or condition.

## SYNTAX

### Filter (Default)
```
Get-XoVbd [-Name <String>] [-Filter <String>] [-Tag <String[]>] [-Limit <Int32>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### VbdUuid
```
Get-XoVbd [-VbdUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get VBD details.
You can specify VBDs by their UUIDs or properties.

## EXAMPLES

### EXAMPLE 1
```
Get-XoVbd -VbdUuid "12345678-abcd-1234-abcd-1234567890ab"
```

## PARAMETERS

### -VbdUuid
The UUID(s) of the VBD(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: VbdUuid
Aliases: $VBDs

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Filter VBDs matching the specified name.

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

### -Filter
Custom filter expression for the VBD query.

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

### -Tag
Filter VBDs matching any of the specified tags.

```yaml
Type: String[]
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Maximum number of VBDs to return.

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

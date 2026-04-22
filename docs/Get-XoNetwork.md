---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoNetwork

## SYNOPSIS
Query networks by UUID or condition.

## SYNTAX

### Filter (Default)
```
Get-XoNetwork [-Name <String>] [-Filter <String>] [-Tag <String[]>] [-Limit <Int32>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### NetworkUuid
```
Get-XoNetwork [-NetworkUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get network details.
You can specify networks by their UUIDs or properties.

## EXAMPLES

### EXAMPLE 1
```
Get-XoNetwork -NetworkUuid "12345678-abcd-1234-abcd-1234567890ab"
```

## PARAMETERS

### -NetworkUuid
The UUID(s) of the network(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: NetworkUuid
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Filter networks matching the specified name.

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
Custom filter expression for the network query.

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
Filter networks matching any of the specified tags.

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
Maximum number of networks to return.

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

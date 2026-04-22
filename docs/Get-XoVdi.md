---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoVdi

## SYNOPSIS
Get VDIs from Xen Orchestra.

## SYNTAX

### Filter (Default)
```
Get-XoVdi [-SrUuid <String>] [-Filter <String>] [-Limit <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### VdiUuid
```
Get-XoVdi [-VdiUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves VDIs from Xen Orchestra.
Can retrieve specific VDIs by their UUID
or filter VDIs by various criteria.

## EXAMPLES

### EXAMPLE 1
```
Get-XoVdi
Returns up to 25 VDIs.
```

### EXAMPLE 2
```
Get-XoVdi -Limit 0
Returns all VDIs without limit.
```

### EXAMPLE 3
```
Get-XoVdi -VdiUuid "12345678-abcd-1234-abcd-1234567890ab"
Returns the VDI with the specified UUID.
```

### EXAMPLE 4
```
Get-XoVdi -SrUuid "12345678-abcd-1234-abcd-1234567890ab"
Returns VDIs on the specified storage repository (up to default limit).
```

### EXAMPLE 5
```
Get-XoVdi -Filter "name_label:backup*"
Returns VDIs with names starting with "backup" (up to default limit).
```

## PARAMETERS

### -VdiUuid
The UUID(s) of the VDI(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: VdiUuid
Aliases: VdiId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SrUuid
Filter VDIs by storage repository UUID.

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
Custom filter to apply to the VDI query.

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

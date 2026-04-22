---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoSr

## SYNOPSIS
Get storage repositories from Xen Orchestra.

## SYNTAX

### Filter (Default)
```
Get-XoSr [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### SrUuid
```
Get-XoSr [-SrUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves storage repositories from Xen Orchestra.
Can retrieve specific SRs by their UUID
or all SRs.

## EXAMPLES

### EXAMPLE 1
```
Get-XoSr
Returns up to 25 SRs.
```

### EXAMPLE 2
```
Get-XoSr -Limit 0
Returns all SRs without limit.
```

### EXAMPLE 3
```
Get-XoSr -SrUuid "a1b2c3d4"
Returns the SR with the specified UUID.
```

### EXAMPLE 4
```
Get-XoSr -Limit 5
Returns the first 5 SRs.
```

## PARAMETERS

### -SrUuid
The UUID(s) of the SR(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: SrUuid
Aliases: SrId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Limit
Maximum number of results to return.
Default is 25 if not specified.
Use -Limit 0 to return all results without limitation.

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

### XoPowershell.Sr
## NOTES

## RELATED LINKS

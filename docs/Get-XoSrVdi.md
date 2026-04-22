---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoSrVdi

## SYNOPSIS
Get virtual disks (VDIs) scoped to a specific storage repository.

## SYNTAX

```
Get-XoSrVdi [-SrUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns the VDIs that live on the specified storage repository.
The XO REST API does not expose a dedicated GET /srs/{id}/vdis endpoint (only POST for VDI uploads), so this cmdlet delegates to Get-XoVdi with the $SR filter.
Accepts one or more SR UUIDs and pipeline input by property name.

## EXAMPLES

### EXAMPLE 1
```
Get-XoSrVdi -SrUuid "c787b75c-3e0d-70fa-d0c3-cbfd382d7e33"
```

### EXAMPLE 2
```
Get-XoSr | Get-XoSrVdi
```

## PARAMETERS

### -SrUuid
The UUID(s) of the storage repository whose virtual disks (VDIs) should be returned.
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

### XoPowershell.Vdi
## NOTES

## RELATED LINKS

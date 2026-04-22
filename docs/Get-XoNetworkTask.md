---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoNetworkTask

## SYNOPSIS
Get tasks scoped to a specific network.

## SYNTAX

```
Get-XoNetworkTask [-NetworkUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves tasks attached to the specified Xen Orchestra network.
Accepts one or more network UUIDs; each is queried independently and the combined results are returned.

## EXAMPLES

### EXAMPLE 1
```
Get-XoNetworkTask -NetworkUuid "00000000-0000-0000-0000-000000000000"
```

### EXAMPLE 2
```
Get-XoNetwork | Get-XoNetworkTask
```

## PARAMETERS

### -NetworkUuid
The UUID(s) of the network whose tasks should be returned.
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

### XoPowershell.Task
## NOTES

## RELATED LINKS

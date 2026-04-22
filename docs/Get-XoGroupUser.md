---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoGroupUser

## SYNOPSIS
Get user scoped to a specific group.

## SYNTAX

```
Get-XoGroupUser [-GroupId] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves user attached to the specified Xen Orchestra group.
Accepts one or more group UUIDs; each is queried independently and the combined results are returned.

## EXAMPLES

### EXAMPLE 1
```
Get-XoGroupUser -GroupId "00000000-0000-0000-0000-000000000000"
```

### EXAMPLE 2
```
Get-XoGroup | Get-XoGroupUser
```

## PARAMETERS

### -GroupId
The UUID(s) of the group whose user should be returned.
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

### XoPowershell.User
## NOTES

## RELATED LINKS

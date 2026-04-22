---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Disconnect-XoSession

## SYNOPSIS
Disconnect from a Xen Orchestra instance.

## SYNTAX

```
Disconnect-XoSession [-ClearCredentials] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Disconnects from the current Xen Orchestra session and optionally clears saved credentials.

## EXAMPLES

### EXAMPLE 1
```
Disconnect-XoSession
Disconnects from the current session.
```

### EXAMPLE 2
```
Disconnect-XoSession -ClearCredentials
Disconnects from the current session and clears saved credentials.
```

## PARAMETERS

### -ClearCredentials
Clears any saved credentials for the current session.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

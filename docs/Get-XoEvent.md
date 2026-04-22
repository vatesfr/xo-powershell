---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoEvent

## SYNOPSIS
List Xen Orchestra events.

## SYNTAX

```
Get-XoEvent [[-Filter] <String>] [[-Limit] <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves entries from the Xen Orchestra event log.
Events represent system-level occurrences (object changes, connection events, user actions).
Useful for audit/troubleshooting.
Supports XO filter expressions and paging.

## EXAMPLES

### EXAMPLE 1
```
Get-XoEvent -Limit 100
```

### EXAMPLE 2
```
Get-XoEvent -Filter 'type:connection-lost'
```

## PARAMETERS

### -Filter
XO filter expression applied server-side (e.g.
\`type:host\`).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Maximum number of events to return.
Defaults to the session limit.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

### XoPowershell.Event
## NOTES

## RELATED LINKS

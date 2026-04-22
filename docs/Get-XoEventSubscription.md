---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoEventSubscription

## SYNOPSIS
List or query subscriptions for a specific Xen Orchestra event.

## SYNTAX

### All (Default)
```
Get-XoEventSubscription [-EventId] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Single
```
Get-XoEventSubscription [-EventId] <String> [-SubscriptionId <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Retrieves webhook/API subscriptions attached to a given event.
A subscription describes where and how Xen Orchestra should notify an external endpoint when the event fires.
Supply -SubscriptionId to fetch a single subscription.

## EXAMPLES

### EXAMPLE 1
```
Get-XoEventSubscription -EventId 'vm-started'
```

### EXAMPLE 2
```
Get-XoEventSubscription -EventId 'vm-started' -SubscriptionId 'sub-123'
```

## PARAMETERS

### -EventId
The ID of the event whose subscriptions to retrieve.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SubscriptionId
Optional ID of a specific subscription to retrieve instead of listing them all.

```yaml
Type: String
Parameter Sets: Single
Aliases:

Required: False
Position: Named
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

## NOTES

## RELATED LINKS

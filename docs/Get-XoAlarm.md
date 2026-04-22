---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoAlarm

## SYNOPSIS
List or query alarms.

## SYNTAX

### Filter (Default)
```
Get-XoAlarm [-BodyName <String>] [-Filter <String>] [-Limit <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### AlarmUuid
```
Get-XoAlarm [-AlarmUuid] <String[]> [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### PoolUuid
```
Get-XoAlarm [-PoolUuid] <String> [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get Xen Orchestra alarms by UUID or list all existing alarms.

## EXAMPLES

### EXAMPLE 1
```
Get-XoAlarm -AlarmUuid "12345678-abcd-1234-abcd-1234567890ab"
```

## PARAMETERS

### -AlarmUuid
The UUID(s) of the alarm(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: AlarmUuid
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -BodyName
Filter alarms matching the specified body name.

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
Custom filter expression for the alarm query.

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

### -PoolUuid
UUID of the pool whose alarms to retrieve.

```yaml
Type: String
Parameter Sets: PoolUuid
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Limit
Maximum number of alarms to return.

```yaml
Type: Int32
Parameter Sets: (All)
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

---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoMessage

## SYNOPSIS
List or query messages.

## SYNTAX

### Filter (Default)
```
Get-XoMessage [-Name <String>] [-Filter <String>] [-Limit <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### MessageUuid
```
Get-XoMessage [-MessageUuid] <String[]> [-Limit <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### PoolUuid
```
Get-XoMessage [-PoolUuid] <String> [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### VmUuid
```
Get-XoMessage [-VmUuid] <String> [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get Xen Orchestra messages by UUID or list all existing messages.

## EXAMPLES

### EXAMPLE 1
```
Get-XoMessage -MessageUuid "12345678-abcd-1234-abcd-1234567890ab"
```

## PARAMETERS

### -MessageUuid
The UUID(s) of the message(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: MessageUuid
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Filter messages matching the specified name.

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
Custom filter expression for the message query.

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
UUID of the pool whose messages to retrieve.

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

### -VmUuid
UUID of the VM whose messages to retrieve.

```yaml
Type: String
Parameter Sets: VmUuid
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Limit
Maximum number of messages to return.

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

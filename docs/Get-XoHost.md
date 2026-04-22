---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoHost

## SYNOPSIS
Get physical hosts from Xen Orchestra.

## SYNTAX

### Filter (Default)
```
Get-XoHost [-Filter <String>] [-PoolUuid <String>] [-Limit <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### HostUuid
```
Get-XoHost [-HostUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves physical XCP-ng/XenServer hosts from Xen Orchestra.
Can retrieve specific hosts by their UUID or filter hosts by various criteria.

## EXAMPLES

### EXAMPLE 1
```
Get-XoHost
Returns up to 25 hosts.
```

### EXAMPLE 2
```
Get-XoHost -Limit 0
Returns all hosts without limit.
```

### EXAMPLE 3
```
Get-XoHost -HostUuid "12345678-abcd-1234-abcd-1234567890ab"
Returns the host with the specified UUID.
```

### EXAMPLE 4
```
Get-XoHost -Filter "power_state:running"
Returns running hosts (up to default limit).
```

## PARAMETERS

### -HostUuid
The UUID(s) of the host(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: HostUuid
Aliases: HostId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Filter
Filter to apply to the host query.

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
UUID of the pool whose hosts to retrieve.

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

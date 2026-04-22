---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoServer

## SYNOPSIS
Get servers from Xen Orchestra.

## SYNTAX

### Filter (Default)
```
Get-XoServer [-Filter <String>] [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ServerUuid
```
Get-XoServer [-ServerUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves servers from Xen Orchestra.
Can retrieve specific servers by their ID
or filter servers by various criteria.

## EXAMPLES

### EXAMPLE 1
```
Get-XoServer
Returns up to 25 servers.
```

### EXAMPLE 2
```
Get-XoServer -Limit 0
Returns all servers without limit.
```

### EXAMPLE 3
```
Get-XoServer -ServerUuid "12345678-abcd-1234-abcd-1234567890ab"
Returns the server with the specified ID.
```

### EXAMPLE 4
```
Get-XoServer -Filter "status:connected"
Returns connected servers (up to default limit).
```

## PARAMETERS

### -ServerUuid
The ID(s) of the server(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: ServerUuid
Aliases: ServerId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Filter
Filter to apply to the server query.

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

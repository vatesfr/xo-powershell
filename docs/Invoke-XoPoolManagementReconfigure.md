---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Invoke-XoPoolManagementReconfigure

## SYNOPSIS
Reconfigure the management network of a Xen Orchestra pool.

## SYNTAX

```
Invoke-XoPoolManagementReconfigure [-PoolUuid] <String> [-NetworkUuid] <String>
 [-AdditionalParameters <Hashtable>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Points the pool's management interface at a different network.
Thin wrapper
around the internal Invoke-XoPoolAction -Action management_reconfigure helper.
Returns a task object that can be passed to Wait-XoTask to monitor completion.

## EXAMPLES

### EXAMPLE 1
```
Invoke-XoPoolManagementReconfigure -PoolUuid $pool.PoolUuid -NetworkUuid $net.NetworkUuid
```

## PARAMETERS

### -PoolUuid
The UUID of the pool whose management network is being reconfigured.

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

### -NetworkUuid
The UUID of the network to use as the new management network.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdditionalParameters
Optional hashtable of extra body parameters to merge into the
management_reconfigure action payload.
Values here override NetworkUuid.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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

### XoPowershell.Task
## NOTES

## RELATED LINKS

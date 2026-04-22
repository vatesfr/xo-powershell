---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# New-XoBondedNetwork

## SYNOPSIS
Create a new bonded network on a Xen Orchestra pool.

## SYNTAX

```
New-XoBondedNetwork [-PoolUuid] <String> [-Name] <String> -PifUuid <String[]> -BondMode <String>
 [-Description <String>] [-AdditionalParameters <Hashtable>] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a bonded network from a set of PIFs on the specified pool.
Thin wrapper
around the internal Invoke-XoPoolAction -Action create_bonded_network helper.
Returns a task object that can be passed to Wait-XoTask to monitor completion.

## EXAMPLES

### EXAMPLE 1
```
New-XoBondedNetwork -PoolUuid $pool.PoolUuid -Name "bond0" -PifUuid $p1,$p2 -BondMode lacp
```

## PARAMETERS

### -PoolUuid
The UUID of the pool to create the bonded network on.

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

### -Name
The name of the new bonded network.

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

### -PifUuid
The UUIDs of the PIFs to bond together.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PifIds

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BondMode
The bonding mode.
Typical values: balance-slb, active-backup, lacp.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Optional description of the new bonded network.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdditionalParameters
Optional hashtable of extra body parameters to merge into the
create_bonded_network action payload.
Values here override the dedicated
parameters above.

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

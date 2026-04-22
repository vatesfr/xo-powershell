---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoVm

## SYNOPSIS
Get VMs from Xen Orchestra.

## SYNTAX

### Filter (Default)
```
Get-XoVm [-PowerState <String[]>] [-Tag <String[]>] [-Filter <String>] [-PoolUuid <String>]
 [-HostUuid <String>] [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### VmUuid
```
Get-XoVm [-VmUuid] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves VMs from Xen Orchestra.
Can retrieve specific VMs by their UUID
or filter VMs by power state, tags, or custom filters.

## EXAMPLES

### EXAMPLE 1
```
Get-XoVm
Returns up to 25 VMs.
```

### EXAMPLE 2
```
Get-XoVm -Limit 0
Returns all VMs without limit.
```

### EXAMPLE 3
```
Get-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
Returns the VM with the specified UUID.
```

### EXAMPLE 4
```
Get-XoVm -PowerState Running
Returns running VMs (up to default limit).
```

### EXAMPLE 5
```
Get-XoVm -Tag "Production"
Returns VMs tagged with "Production" (up to default limit).
```

### EXAMPLE 6
```
Get-XoVm -Filter "name_label:test*"
Returns VMs with names starting with "test" (up to default limit).
```

## PARAMETERS

### -VmUuid
The UUID(s) of the VM(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: VmUuid
Aliases: VmId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PowerState
Filter VMs by power state.
Valid values: Running, Halted, Suspended.

```yaml
Type: String[]
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Filter VMs by one or more tags.

```yaml
Type: String[]
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Custom filter to apply to the VM query.

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
UUID of the pool whose VMs to retrieve.

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

### -HostUuid
UUID of the host whose VMs to retrieve.

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

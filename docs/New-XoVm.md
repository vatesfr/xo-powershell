---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# New-XoVm

## SYNOPSIS
Create a new VM on a Xen Orchestra pool.

## SYNTAX

```
New-XoVm [-PoolUuid] <String> [-Name] <String> -TemplateUuid <String> [-Description <String>]
 [-HostUuid <String>] [-CPUs <Int32>] [-MemoryBytes <Int64>] [-AdditionalParameters <Hashtable>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new VM on the specified pool from a VM template.
Thin wrapper around the
internal Invoke-XoPoolAction -Action create_vm helper.
Returns a task object that
can be passed to Wait-XoTask to monitor completion.

## EXAMPLES

### EXAMPLE 1
```
New-XoVm -PoolUuid $pool.PoolUuid -Name "web-01" -TemplateUuid $tpl.VmTemplateUuid
```

### EXAMPLE 2
```
New-XoVm -PoolUuid $pool.PoolUuid -Name "web-01" -TemplateUuid $tpl.VmTemplateUuid -HostUuid $host.HostUuid -CPUs 2 -MemoryBytes 2147483648
```

## PARAMETERS

### -PoolUuid
The UUID of the pool to create the VM on.

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
The name_label to assign to the new VM.

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

### -TemplateUuid
The UUID of the VM template to clone from.
See Get-XoVmTemplate.

```yaml
Type: String
Parameter Sets: (All)
Aliases: TemplateId

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Optional name_description for the new VM.

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

### -HostUuid
Optional UUID of the host the VM should prefer (affinity).
See Get-XoHost.

```yaml
Type: String
Parameter Sets: (All)
Aliases: AffinityHost

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CPUs
Optional number of virtual CPUs to assign to the new VM.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemoryBytes
Optional amount of memory, in bytes, to assign to the new VM.

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdditionalParameters
Optional hashtable of extra body parameters to merge into the create_vm action
payload.
Values in this hashtable override any of the dedicated parameters above.

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

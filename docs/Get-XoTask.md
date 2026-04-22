---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoTask

## SYNOPSIS
Get tasks from Xen Orchestra.

## SYNTAX

### Filter (Default)
```
Get-XoTask [-Status <String>] [-Limit <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### TaskId
```
Get-XoTask [-TaskId] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves tasks from Xen Orchestra.
Can retrieve specific tasks by their ID
or filter tasks by status.

## EXAMPLES

### EXAMPLE 1
```
Get-XoTask
Returns up to 25 tasks of any status.
```

### EXAMPLE 2
```
Get-XoTask -Status failure
Returns failed tasks.
```

### EXAMPLE 3
```
Get-XoTask -TaskId "0m8k2zkzi"
Returns the task with the specified ID.
```

### EXAMPLE 4
```
Get-XoTask -Limit 5
Returns the first 5 tasks.
```

## PARAMETERS

### -TaskId
The ID(s) of the task(s) to retrieve.

```yaml
Type: String[]
Parameter Sets: TaskId
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Status
Filter tasks by status.
Valid values: pending, success, failure.

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

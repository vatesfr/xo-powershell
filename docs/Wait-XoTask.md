---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Wait-XoTask

## SYNOPSIS
Wait for task completion.

## SYNTAX

```
Wait-XoTask [-TaskId] <String[]> [-PassThru] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Waits for the specified tasks to complete and optionally returns the result.

## EXAMPLES

### EXAMPLE 1
```
Wait-XoTask -TaskId "0m8k2zkzi"
Waits for the task to complete.
```

### EXAMPLE 2
```
Wait-XoTask -TaskId "0m8k2zkzi" -PassThru
Waits for the task to complete and returns the task object.
```

## PARAMETERS

### -TaskId
The ID(s) of the task(s) to wait for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassThru
If specified, returns the task objects after completion.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

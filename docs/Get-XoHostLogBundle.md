---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoHostLogBundle

## SYNOPSIS
Download the diagnostic log bundle for a Xen Orchestra host.

## SYNTAX

```
Get-XoHostLogBundle [-HostUuid] <String> [-OutFile <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Downloads the compressed .tgz log bundle from /hosts/{id}/logs.tgz.
The bundle contains xensource.log, messages, xapi database dumps and other data that support engineers typically ask for.
When -OutFile is supplied the file is written to disk.

## EXAMPLES

### EXAMPLE 1
```
Get-XoHostLogBundle -HostUuid "812b59e1-2682-43ef-acd4-808d3551b907" -OutFile "./host-logs.tgz"
```

## PARAMETERS

### -HostUuid
The UUID of the host whose log bundle to download.

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

### -OutFile
Path to save the downloaded .tgz to.
If omitted, content is streamed back as bytes.

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

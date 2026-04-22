---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoHostAudit

## SYNOPSIS
Download the audit log for a Xen Orchestra host.

## SYNTAX

```
Get-XoHostAudit [-HostUuid] <String> [-OutFile <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Downloads the plain-text XAPI audit log from /hosts/{id}/audit.txt.
When -OutFile is supplied the file is written to disk; otherwise the content is returned as a string.
Useful for compliance reporting and forensic investigation.

## EXAMPLES

### EXAMPLE 1
```
Get-XoHostAudit -HostUuid "812b59e1-2682-43ef-acd4-808d3551b907" -OutFile "./host-audit.txt"
```

### EXAMPLE 2
```
Get-XoHost | ForEach-Object { Get-XoHostAudit -HostUuid $_.HostUuid -OutFile "./audit-$($_.Name).txt" }
```

## PARAMETERS

### -HostUuid
The UUID of the host whose audit log to download.

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
Path to save the downloaded content to.
If omitted, content is returned as a string.

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

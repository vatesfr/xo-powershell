---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoBackupRepository

## SYNOPSIS
List or query Xen Orchestra backup repositories.

## SYNTAX

### Filter (Default)
```
Get-XoBackupRepository [-Filter <String>] [-Limit <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### BackupRepositoryId
```
Get-XoBackupRepository [-BackupRepositoryId] <String[]> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Retrieves backup repositories (remotes) configured in Xen Orchestra - the destinations where backup archives are stored.
When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -BackupRepositoryId to fetch specific entries or -Filter / -Limit to scope a list query.

## EXAMPLES

### EXAMPLE 1
```
Get-XoBackupRepository | Where-Object enabled
```

### EXAMPLE 2
```
"
```

## PARAMETERS

### -BackupRepositoryId
One or more IDs of the backup repositories to retrieve.
When omitted, the cmdlet enumerates backup repositories using Filter and Limit.

```yaml
Type: String[]
Parameter Sets: BackupRepositoryId
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Filter
XO filter expression applied server-side (same syntax as the REST \`filter\` query parameter, e.g.
\`status:success\`).

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
Maximum number of backup repositories to return when listing.
Defaults to the session limit set by Connect-XoSession or Set-XoSession.

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

### XoPowershell.BackupRepository
## NOTES

## RELATED LINKS

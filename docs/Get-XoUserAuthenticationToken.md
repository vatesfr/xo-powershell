---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Get-XoUserAuthenticationToken

## SYNOPSIS
List authentication tokens for a specific user.

## SYNTAX

```
Get-XoUserAuthenticationToken [-UserId] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the API authentication tokens owned by a user via GET /users/{id}/authentication_tokens.
Each token includes the client id, description, creation/expiration timestamps and most recent use.
Useful for auditing long-lived tokens created via xo-cli.
The REST API does not expose a "self" variant for listing (only for creation), so a UserId is required.

## EXAMPLES

### EXAMPLE 1
```
Get-XoUserAuthenticationToken -UserId '722d17b9-699b-49d2-8193-be1ac573d3de'
```

### EXAMPLE 2
```
Get-XoUser | Get-XoUserAuthenticationToken
```

## PARAMETERS

### -UserId
The UUID of the user whose authentication tokens should be returned.

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

### XoPowershell.UserAuthenticationToken
## NOTES

## RELATED LINKS

---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Connect-XoSession

## SYNOPSIS
Connect to a Xen Orchestra instance.

## SYNTAX

### Token (Default)
```
Connect-XoSession [-HostName] <String> [-Token <String>] [-Limit <Int32>] [-SaveCredentials]
 [-SkipCertificateCheck] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Credential
```
Connect-XoSession [-HostName] <String> -Credential <PSCredential> [-Limit <Int32>] [-SaveCredentials]
 [-SkipCertificateCheck] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Establishes a connection to a Xen Orchestra instance using either token-based or credential-based authentication.

## EXAMPLES

### EXAMPLE 1
```
Connect-XoSession -HostName "https://xo.example.com" -Token "your-api-token"
Connects to the specified Xen Orchestra instance using a token.
```

### EXAMPLE 2
```
Connect-XoSession -HostName "https://xo.example.com"
Prompts for a token and connects to the specified Xen Orchestra instance.
```

## PARAMETERS

### -HostName
The URL of the Xen Orchestra instance.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Credentials for authentication (not currently implemented).

```yaml
Type: PSCredential
Parameter Sets: Credential
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token
API token for authentication.

```yaml
Type: String
Parameter Sets: Token
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Default page size limit for query cmdlets.

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

### -SaveCredentials
Save credentials for future sessions.

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

### -SkipCertificateCheck
Skips certificate validation (not recommended for production).

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

### System.Boolean
## NOTES

## RELATED LINKS

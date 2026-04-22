---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# New-XoUser

## SYNOPSIS
Create a new Xen Orchestra user.

## SYNTAX

```
New-XoUser [-Credential] <PSCredential> [-Permission <String>] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new user via POST /users.
The name and password are supplied together as a PSCredential so the password never has to sit in a plain-text variable.
Permission defaults to 'none' (read-only).

## EXAMPLES

### EXAMPLE 1
```
New-XoUser -Credential (Get-Credential) -Permission viewer
```

### EXAMPLE 2
```
$cred = [pscredential]::new("alice@example.com", (ConvertTo-SecureString "s3cret" -AsPlainText -Force))
New-XoUser -Credential $cred
```

## PARAMETERS

### -Credential
PSCredential whose UserName becomes the XO user name and whose Password is sent to XO as the initial password.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Permission
Permission level for the new user: 'none', 'viewer' (read-only), or 'admin'.
Defaults to 'none'.

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

### XoPowershell.User
## NOTES

## RELATED LINKS

---
external help file: xo-powershell-help.xml
Module Name: xo-powershell
online version:
schema: 2.0.0
---

# Set-XoUser

## SYNOPSIS
Update a Xen Orchestra user.

## SYNTAX

```
Set-XoUser [-UserId] <String> [-Credential <PSCredential>] [-Permission <String>] [-Preferences <Hashtable>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Edits an existing user via PATCH /users/{id}.
Any combination of Credential, Permission, or Preferences may be supplied; omitted fields are left unchanged.
When Credential is supplied, both the user name and password are sent (XO treats them as a pair on update).

## EXAMPLES

### EXAMPLE 1
```
Set-XoUser -UserId "722d17b9-699b-49d2-8193-be1ac573d3de" -Permission admin
```

### EXAMPLE 2
```
Set-XoUser -UserId "722d17b9-699b-49d2-8193-be1ac573d3de" -Credential (Get-Credential)
```

## PARAMETERS

### -UserId
The UUID of the user to update.

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

### -Credential
PSCredential holding the new user name and password to assign.
The UserName is sent as 'name' and the password is sent in the request body.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Permission
New permission level: 'none', 'viewer', or 'admin'.

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

### -Preferences
Hashtable of preference key/values to store on the user.

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

## NOTES

## RELATED LINKS

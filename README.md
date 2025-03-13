# Powershell module for XO/XOA

## Requirements :
Powershell 7+

## Authentication :
You need to have your XOA endpoint_url and a valid token. You can either authenticate with a configuration file or dynamically.

from file : edit the xoa-credentials.json.sample file to configure your endpoint and your token, then rename the file to xoa-credentials.json
dynamically : don't change anything in the sample configuration file. You will be asked for the endpoint and the token. 

## Usage :
```
- open a powershell windows
- cd where_you_have_extracted_this_module
- Import-Module ./xoa-cli.psd1
- use any cli command described below 
```

#### CLI commands : 

List alls vms 

```pwsh
XoVms-List 
```

Get a VM details

```pwsh
XoVms-Details vmID 
```
Execute standard action on a VM (actioName can be "start", "clean_reboot", "hard_reboot", "clean_shutdown", "hard_shutdown") 

```pwsh
XoVms-Action vmID actionName 
```

Make a snapshot

```pwsh
XoVms-Snapshot vmID
```

List all tasks

```pwsh
XoTasks-List
```

Get a task detail

```pwsh
XoTasks-Details taskID
```
 
## Contributions

## License
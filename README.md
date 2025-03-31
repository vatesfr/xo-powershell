# PowerShell Module for Xen Orchestra

A PowerShell module to interact with Xen Orchestra's REST API, allowing you to manage your XenServer/XCP-ng virtualization environment directly from PowerShell.

## Requirements
- PowerShell 7.0 or later
- Access to a Xen Orchestra instance
- A valid API token

## Installation

1. Clone this repository or download the module files
2. Place them in a directory of your choice
3. Import the module:

```powershell
Import-Module ./xo-powershell.psd1
```

## Authentication

You need to authenticate with your Xen Orchestra instance before running commands:

### Using a token directly

```powershell
Connect-XoSession -HostName "https://your-xo-server" -Token "your-api-token"
```

## Available Commands

### Session Management
- `Test-XoSession` - Test connection to Xen Orchestra
- `Connect-XoSession` - Connect to Xen Orchestra (`Connect-XenOrchestra` is an alias)
- `Disconnect-XoSession` - Disconnect from Xen Orchestra (`Disconnect-XenOrchestra` is an alias)

### VM Management
- `Get-XoVm` - Get list of VMs or a specific VM
- `Start-XoVm` - Start one or more VMs
- `Stop-XoVm` - Stop one or more VMs (use -Force for hard shutdown)
- `Restart-XoVm` - Restart one or more VMs (use -Force for hard reboot)
- `New-XoVmSnapshot` - Create VM snapshot
- `Get-XoVmSnapshot` - Get VM snapshots
- `Suspend-XoVm` - Suspend one or more VMs

### Storage Management
- `Get-XoSr` - Get storage repositories
- `Get-XoVdi` - Get virtual disk images
- `Get-XoVmVdi` - Get disks attached to a VM
- `Export-XoVdi` - Export a VDI to a file in VHD or RAW format

### VDI Snapshot Management
- `Get-XoVdiSnapshot` - Get VDI snapshots
- `Export-XoVdiSnapshot` - Export a VDI snapshot to a file in VHD or RAW format

### Server Management
- `Get-XoServer` - Get server information

### Host Management
- `Get-XoHost` - Get host information

### Task Management
- `Get-XoTask` - Get task information (`Get-XoTaskDetails` is an alias)
- `Wait-XoTask` - Wait for task completion

## Examples

### Working with VMs

List all running VMs:
```powershell
Get-XoVm -PowerState Running
```

Get a specific VM:
```powershell
Get-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
```

Start multiple VMs:
```powershell
Get-XoVm -PowerState Halted | Start-XoVm
```

Create a snapshot of a VM:
```powershell
New-XoVmSnapshot -VmUuid "12345678-abcd-1234-abcd-1234567890ab" -SnapshotName "Before Update"
```

### Working with Disks

Get all disks for a VM:
```powershell
Get-XoVmVdi -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
```

Export a VDI to a file:
```powershell
Export-XoVdi -VdiId "a1b2c3d4" -Format vhd -OutFile "C:\exports\disk_backup.vhd"
```

### Working with Servers and Hosts

List all servers:
```powershell
Get-XoServer
```

List all hosts:
```powershell
Get-XoHost
```

## Pipeline Support

Most commands support pipeline input, allowing for operations like:

```powershell
Get-XoVm | Where-Object { $_.Name -like "*Test*" } | Stop-XoVm
```

```powershell
Get-XoVm -PowerState Running | Where-Object { $_.Memory -gt 4GB } | Suspend-XoVm
```

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
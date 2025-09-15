# Windows Script Launcher - Control Center

A comprehensive script-based launcher for managing and executing Windows system administration tools. This launcher provides centralized access to various system management utilities with a clean, user-friendly interface.

<img width="1108" height="375" alt="image" src="https://github.com/user-attachments/assets/021513a1-d946-4e48-afaa-223854112e1d" />

## 🚀 Features

- **Centralized Control**: Single entry point for all system management scripts
- **Cross-Platform Script Support**: Executes both `.bat` and `.ps1` files seamlessly
- **Return-to-Menu Functionality**: After executing any module, automatically returns to the main menu
- **Administrator Privilege Management**: Handles UAC elevation automatically
- **Script Status Monitoring**: Shows availability status of all modules
- **Detailed Help System**: Comprehensive information about each tool
- **Error Handling**: Graceful handling of missing files and execution errors
 
## risunCode winScript Online Launcher
- or just download winscript from Releases tab!
```cmd
irm "https://raw.githubusercontent.com/risunCode/WinPortal/main/winScript/WinScriptLauncher.ps1" | iex
```

### Prerequisites

- **Windows 10/11** (Administrator privileges required)
- **PowerShell** (for Windows Update Controller)
- **Network adapter with WiFi support** (for WiFi Manager)

### Installation Steps

1. **Download/Clone** the repository to your preferred location
2. **Ensure all script files** are present in their respective folders
3. **Right-click** on `WinScriptLauncher.bat`
4. **Select "Run as Administrator"** (or the launcher will request elevation automatically)

## 🎯 Usage Guide

### Starting the Launcher

1. Navigate to the `winScript` folder
2. Run `WinScriptLauncher.bat` as Administrator
3. The launcher will automatically check for and request elevated privileges
4. The main menu will display with all available tools

### Main Menu Options

```
[1] System Cache Cleaner          - Clean temporary files, browser cache, and system junk
[2] Chrome Policy Remover         - Remove Chrome management policies and restrictions  
[3] Power Management Suite        - Advanced shutdown, restart, and power options
[4] Windows Update Controller     - Delay or pause Windows updates
[5] WiFi Profile Manager          - Backup, restore, and manage WiFi profiles
[6] TTL Bypass Tool               - Modify TTL settings for tethering bypass

[R] Refresh Menu                  - Reload the launcher interface
[H] Help / About                  - Show detailed information about each tool
[Q] Quit Launcher                 - Exit the application
```

### Navigation

- **Select an option** by typing the corresponding number or letter
- **After any tool finishes**, you'll automatically return to the main menu
- **Use 'R'** to refresh the menu and check script status
- **Use 'H'** for detailed help and tool descriptions
- **Use 'Q'** to exit the launcher

## 🛠️ Available Tools

### 1. System Cache Cleaner
- **Purpose**: Clean temporary files and system junk
- **Features**:
  - Cleans user and system temporary directories
  - Removes browser cache (Chrome, Firefox, Edge)
  - Clears prefetch files and recent items
  - Optional Recycle Bin cleaning (Deep Clean mode)
  - Creates detailed log files
- **File**: `CacheCleaner\wintrace_cleaner.bat`

### 2. Chrome Policy Remover
- **Purpose**: Remove Chrome management policies
- **Features**:
  - Removes "Managed by your organization" settings
  - Clears Chrome registry entries and policy files
  - Removes Chrome preferences with policy settings
  - Handles both 32-bit and 64-bit registry entries
- **File**: `ChromePolicy\Chrome_Policy_Remover.bat`
- **Note**: Close Chrome before running

### 3. Power Management Suite
- **Purpose**: Advanced power management operations
- **Features**:
  - Multiple shutdown options (normal, forced)
  - System restart modes (normal, soft, UEFI)
  - Sleep and hibernation modes
  - Custom shutdown command execution
  - Action logging with timestamps
- **File**: `PowerManager\NewShutdown.bat`

### 4. Windows Update Controller
- **Purpose**: Control Windows Update behavior
- **Features**:
  - Pause Windows Updates until specified year (default: 2050)
  - Custom year selection for update delays
  - Windows Update service management
  - Registry modification for update control
- **File**: `WindowsUpdate\UpdateDelay.ps1` (PowerShell)

### 5. WiFi Profile Manager
- **Purpose**: Comprehensive WiFi profile management
- **Features**:
  - Backup all WiFi profiles with passwords
  - Restore profiles from backups
  - View saved profiles and passwords
  - Selective restoration of specific profiles
  - Search profiles by name
  - Complete profile removal
- **File**: `WindowsWifiBackupRestore\WinWifiManager.bat`

### 6. TTL Bypass Tool
- **Purpose**: Modify network TTL settings
- **Features**:
  - Modify TTL (Time To Live) for IPv4 and IPv6
  - Bypass tethering throttling restrictions
  - Preset values (65, 128) or custom values (1-255)
  - Real-time TTL value display
  - Input validation and error handling
- **File**: `WinTTLBypass\WinTTLBypass.bat`

## ⚠️ Important Notes

### Security & Safety

- **Administrator Privileges**: Required for most operations
- **System Modifications**: Tools modify system settings and may require reboot
- **Backup Recommended**: Always backup important data before using system modification tools
- **Corporate Environments**: Some corporate/domain policies may override modifications

### Troubleshooting

#### Script Not Found Errors
- Ensure all folders and script files are present
- Check the project structure matches the layout above
- Verify file permissions allow execution

#### UAC/Permission Issues
- Always run the launcher as Administrator
- If UAC prompts appear, click "Yes" to grant privileges
- Some antivirus software may block script execution

#### PowerShell Execution Policy
- The launcher automatically handles PowerShell execution policy
- If issues persist, run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

## 🔄 How It Works

### Launcher Architecture

1. **Entry Point**: `WinScriptLauncher.bat` serves as the main gateway
2. **Privilege Check**: Automatically requests administrator elevation
3. **Menu System**: Displays available tools and status
4. **Script Execution**: Uses `call` command for `.bat` files and `powershell` for `.ps1` files
5. **Return Mechanism**: Each tool returns to the launcher upon completion

### Return-to-Menu Implementation

- **Batch Files**: Use `call` command instead of direct execution to maintain parent process
- **PowerShell Scripts**: Executed with specific parameters to return control
- **Error Handling**: Missing files are detected and reported without crashing
- **Status Monitoring**: Real-time check of script availability

### Cross-Platform Script Support

The launcher intelligently handles different script types:

- **`.bat` files**: Executed using `call "path\to\script.bat"`
- **`.ps1` files**: Executed using `powershell -ExecutionPolicy Bypass -File "path\to\script.ps1"`
- **Error Handling**: File existence checks before execution
- **Path Management**: Maintains proper working directory context

## 📝 Logs and Output

### Individual Tool Logs
- Each tool may create its own log files
- Check tool-specific directories for detailed logs
- Timestamps are included for tracking execution history

### Launcher Status
- Script availability is checked in real-time
- Missing scripts are clearly identified
- Execution status is displayed after each tool runs

## 🚨 Best Practices

1. **Always run as Administrator** for full functionality
2. **Close relevant applications** before running system modification tools
3. **Read tool descriptions** in the Help section before use
4. **Backup important data** before using system modification tools
5. **Test in non-production environments** first when possible
6. **Check logs** for detailed information about tool execution

## 🤝 Support

If you encounter issues:

1. **Check Prerequisites**: Ensure Windows 10/11 and Administrator privileges
2. **Verify File Structure**: Confirm all scripts are in their correct locations
3. **Review Logs**: Check individual tool logs for specific error messages
4. **Use Help System**: Press 'H' in the main menu for detailed tool information

---

**Created by**: Windows Script Launcher Project  
**Version**: 1.0  
**Last Updated**: September 2025  

Happy scripting! 🚀



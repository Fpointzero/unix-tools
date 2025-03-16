# wsl-tools

[English](README.md) | [中文版](README.zh-CN.md)

`wsl-tools` is a toolset based on PowerShell and bash, designed to manage and operate the Windows Subsystem for Linux (WSL).

It provides a `git-credential-helper.sh` script for encrypting and decrypting Git credentials to ensure secure storage of sensitive information.

Additionally, it offers WSL management features such as backup, restore, and migration of WSL distributions, simplifying WSL management. It also includes related functionalities for WSL interaction with Windows.

## Project Purpose

- **Simplify WSL Management**: Reduce the need for manually entering complex WSL commands through intuitive command-line tools.
- **Backup and Restore**: Supports exporting WSL distributions as backup files and quickly restoring them when needed.
- **Modular Design**: Each functional module is implemented independently, making it easy to extend and maintain.

## Module: `wsl`
## Usage

Clone the project locally:
```bash
git clone https://github.com/Fpointzero/wsl-tools.git
cd wsl-tools/wsl
```

### `wsl-manager`

`wsl-manager.ps1` is a PowerShell script for managing Windows Subsystem for Linux (WSL). Below are its main functions.

1. List all distributions
    ```powershell
    ./wsl-manager.ps1
    === WSL Manager ===
    1. List WSL distros
    2. Backup a WSL distro
    3. Restore a WSL distro
    4. Migrate a WSL distro
    5. Exit
    Enter your choice (1-5): 1
    Listing all WSL distros...
    WSL Distros:
    1: Name=Ubuntu-24.04, State=Stopped, Version=2
    2: Name=Arch, State=Stopped, Version=2
    3: Name=Test, State=Stopped, Version=2
    ```

2. Backup a distribution: Export the specified WSL distribution as a `.tar` backup file.
    ```powershell
    ./wsl-manager.ps1
    === WSL Manager ===
    1. List WSL distros
    2. Backup a WSL distro
    3. Restore a WSL distro
    4. Migrate a WSL distro
    5. Exit
    Enter your choice (1-5): 2 # User input
    Select distro to backup:
    1: Ubuntu-24.04
    2: Arch
    2 # User input
    Enter backup directory:
    D:\WSL\Arch # User input
    Exporting WSL distro to "D:\WSL\Arch\Arch.tar" ...
    Operation completed successfully. 
    Exporting, this may take a few minutes. 

    Operation completed successfully.
    Backup completed successfully!
    ```

3. Restore a distribution: Import and restore the specified `.tar` backup file as a WSL distribution.
    ```powershell
    ./wsl-manager.ps1
    === WSL Manager ===
    1. List WSL distros
    2. Backup a WSL distro
    3. Restore a WSL distro
    4. Migrate a WSL distro
    5. Exit
    Enter your choice (1-5): 3 # User input
    Restore a WSL distro from backup...
    Enter the path to the backup file (.tar):
    D:\WSL\Arch\Arch.tar # User input
    Enter the name for the restored distro:
    Test # User input
    Enter the target directory for the restored distro:
    D:\WSL\Test # User input
    Importing WSL distro from backup file...
    Operation completed successfully. 
    Restoration completed successfully!
    ```

4. Migrate a distribution: Migrate the specified distribution to another directory (e.g., if the newly installed distribution is on the C drive but you want to move it to the D drive).
    ```powershell
    ./wsl-manager.ps1
    === WSL Manager ===
    1. List WSL distros
    2. Backup a WSL distro
    3. Restore a WSL distro
    4. Migrate a WSL distro
    5. Exit
    Enter your choice (1-5): 4
    Migrating a WSL distro...
    Select distro to migrate:
    1: Ubuntu-24.04
    2: Arch
    3: Test
    3
    Enter the target directory for migration:
    D:\WSL\Temp
    Exporting WSL distro to temporary file...
    Operation completed successfully.
    Exporting, this may take a few minutes. (24190 MB)

    Operation completed successfully.
    Importing WSL distro to new location...
    Unregistering.
    Operation completed successfully. 

    Operation completed successfully. 
    Migration completed successfully!
    ```

5. Follow the prompts to use different features.

### `proxy-function`

`proxy-function.sh` contains quick configuration functions for WSL proxies.

Usage:
```bash
source ./proxy-function.sh
# Set proxy
setproxy 127.0.0.1:10808
# Clear proxy
clearproxy
```

If you want to use Clash or V2Ray in the Windows system as a proxy, you can combine it with the following from `wsl-env.sh`:
```bash
# If WSL does not have DNS proxy enabled
export WIN_IP=$(ip route | grep default | awk '{print $3}')
# If DNS proxy is enabled, you can use the following command to get the Windows IP address
export WIN_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
# Combine usage
setproxy $WIN_IP:10808
```

To fix the WSL proxy IP method: Use Windows host configuration to set an arbitrary network interface address, then configure any domain's hosts to point to that address, and use that domain as the proxy IP in WSL.

Windows hosts configuration:
```hosts
fpointzero.localhost 192.168.31.5
```

WSL proxy configuration:
```bash
setproxy fpointzero.localhost:10808
```

## Module: `git`
`git-credential-helper.sh` is a Git credential manager used to manage Git credentials. It uses OpenSSL for encryption storage, with AES as the encryption algorithm.

Parameter parsing:
```bash
--file Specify the credential storage file path, default is ~/.custom-git-credentials
--secret-key Specify the encryption key, default is your-secret-key
```

Usage:
```bash
git config --global credential.helper "/usr/local/bin/git-credential-helper.sh --file ~/.custom-git-credentials --secret-key your-secret-key"
```

## Contribution

Contributions are welcome! If you have new feature suggestions or find issues, please submit an Issue or Pull Request.
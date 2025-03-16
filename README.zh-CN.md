# wsl-tools

[English](README.md) | [中文版](README.zh-CN.md)

`wsl-tools` 是一个基于 PowerShell, bash 的工具集，用于管理和操作 Windows Subsystem for Linux (WSL)。

提供了一个git-credential-helper.sh脚本，用于加密和解密Git凭据，以确保敏感信息的安全存储。

同时还提供了WSL管理功能，包括WSL分发版的备份，恢复，迁移等操作，简化了WSL的管理。同时在此基础上还提供了相关WSL与Windows交互功能。

## 项目作用

- **简化 WSL 管理**：通过直观的命令行工具，减少手动输入复杂 WSL 命令的需求。
- **备份与恢复**：支持将 WSL 分发版导出为备份文件，并在需要时快速恢复。
- **模块化设计**：每个功能模块独立实现，便于扩展和维护。

## 模块：`wsl`
## 使用方法

将项目克隆到本地：
```bash
git clone https://github.com/Fpointzero/wsl-tools.git
cd wsl-tools/wsl
```

### `wsl-manager`

`wsl-manager.ps1`是一个用于管理Windows Subsystem for Linux (WSL)的PowerShell脚本，下面是主要的功能。

1. 列出所有分发版
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

2. 备份分发版：将指定的 WSL 分发版导出为 `.tar` 备份文件。
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
    操作成功完成。 
    正在导出，这可能需要几分钟时间。 

    操作成功完成。
    Backup completed successfully!
    ```

3. 还原分发版：将指定的`tar`备份文件导入并恢复为WSL分发版。
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
    操作成功完成。 
    Restoration completed successfully!
    ```

4. 迁移分发版：将指定的发行版迁移到其他目录（例如刚安装的发行版在C盘，但希望迁移到D盘）
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
    操作成功完成。
    正在导出，这可能需要几分钟时间。 (24190 MB)

    操作成功完成。
    Importing WSL distro to new location...
    正在注销。
    操作成功完成。 

    操作成功完成。 
    Migration completed successfully!
    ```

5. 根据提示使用不同的功能。

### `proxy-function`

`proxy-function.sh`包含了快速配置WSL代理的函数。

使用方法:
```bash
source ./proxy-function.sh
# 设置代理
setproxy 127.0.0.1:10808
# 清除代理
clearproxy
```

如果想要使用Windows系统的clash或者v2ray作为代理，可以结合使用`wsl-env.sh`中的:
```bash
# 如果没有wsl开启dns代理
export WIN_IP=$(ip route | grep default | awk '{print $3}')
# 如果开启了dns代理，可以使用下面的命令获取windows的ip地址
export WIN_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
# 结合使用
setproxy $WIN_IP:10808
```

固定wsl代理ip的方法: 使用windows host配置windows任意网卡接口地址，然后配置任意域名hosts指向该地址，然后在wsl中使用该域名作为代理ip。

windows配置hosts:
```hosts
fpointzero.localhost 192.168.31.5
```

wsl配置代理:
```bash
setproxy fpointzero.localhost:10808
```

## 模块：`git`
git-credential-helper.sh是一个git凭证管理器，可以用来管理git的凭证。使使用openssl来进行加密存储，加密算法为AES。

参数解析：
```bash
--file 指定凭证存储文件路径，默认为~/.custom-git-credentials
--secret-key 指定加密密钥，默认为your-secret-key
```

使用方法:
```bash
git config --global credential.helper "/usr/local/bin/git-credential-helper.sh --file ~/.custom-git-credentials --secret-key your-secret-key"
```

## 贡献

欢迎贡献代码！如果你有新的功能建议或发现了问题，请提交 Issue 或 Pull Request。
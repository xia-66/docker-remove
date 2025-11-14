# Docker Complete Uninstall Script

这是一个强大且易于使用的 Shell 脚本，用于在 Linux 系统上彻底卸载 Docker。它可以一站式完成停止容器、卸载软件包、清理数据和删除配置文件等所有操作。

This is a powerful and easy-to-use shell script for completely uninstalling Docker on a Linux system. It handles stopping containers, uninstalling packages, cleaning up data, and removing configuration files in one go.

---

## ⚠️ 重要警告 (Important Warning)

此脚本会**永久性地删除**你系统上的所有 Docker 数据，包括：
-   所有 Docker 镜像 (Images)
-   所有 Docker 容器 (Containers)
-   所有 Docker 卷 (Volumes)
-   所有自定义的 Docker 网络 (Networks)

**在运行此脚本之前，请务必备份任何你需要保留的重要数据（例如数据库卷中的数据）。数据一旦删除，将无法恢复！**

## 🚀 一键卸载 (One-Click Uninstall)

在你的终端中复制并粘贴以下任一命令，即可自动下载并执行卸载脚本。脚本需要 `sudo` 权限运行。

**使用 `curl` (推荐):**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xia-66/docker-remove/main/uninstall_docker.sh)"
```

**或者使用 `wget`:**
```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/xia-66/docker-remove/main/uninstall_docker.sh)"
```
> 这条命令会从 GitHub 下载脚本并通过管道直接交给 `bash` 执行。脚本内部会自动请求 `sudo` 权限。如果脚本因为权限问题卡住，请尝试 `curl ... | sudo bash` 的方式。

---

## ✨ 功能特性 (Features)

-   **自动检测包管理器**: 自动识别系统是使用 `apt` (Debian/Ubuntu) 还是 `dnf`/`yum` (CentOS/RHEL/Fedora)。
-   **停止所有活动**: 在卸载前，脚本会自动停止所有正在运行的容器和 Docker 服务。
-   **彻底卸载**: 不仅移除 Docker 相关的软件包，还会清理所有残留数据。
-   **数据清理**: 删除所有 Docker 数据，包括**镜像、容器、卷 (Volumes) 和网络配置**。
-   **安全确认**: 在执行最危险的数据删除操作前，会要求用户输入 `yes` 进行最终确认，防止意外操作。
-   **清晰的输出**: 脚本的每一步都有清晰的日志输出，让你能实时了解执行进度。

## 🛠️ 分步手动执行 (Manual Execution)

如果你不希望直接执行远程脚本，也可以按照以下步骤手动操作。

1.  **克隆本仓库**
    ```bash
    git clone https://github.com/xia-66/docker-remove.git
    ```

2.  **进入项目目录**
    ```bash
    cd docker-remove
    ```

3.  **赋予脚本执行权限**
    ```bash
    chmod +x uninstall_docker.sh
    ```

4.  **以 root 权限运行脚本**
    ```bash
    sudo ./uninstall_docker.sh
    ```

## 💻 支持的操作系统 (Supported OS)

-   Debian / Ubuntu (and their derivatives)
-   CentOS / RHEL / Fedora (and their derivatives)

## 📜 许可证 (License)

本项目采用 [MIT License](LICENSE) 授权。

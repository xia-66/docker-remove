#!/bin/bash

# ==============================================================================
# Docker & Docker Compose 完全卸载脚本
#
# 描述:
#   该脚本用于在 Linux 系统上彻底卸载 Docker 引擎、CLI、containerd、
#   Docker Compose 以及相关的插件。它会停止所有正在运行的容器，删除所有
#   相关的软件包，并清除所有 Docker 数据，包括镜像、容器、卷和网络配置。
#
# 支持的系统:
#   - 基于 Debian/Ubuntu (使用 apt)
#   - 基于 RHEL/CentOS/Fedora (使用 dnf/yum)
#
# 使用方法:
#   1. 将此脚本保存为 uninstall_docker.sh
#   2. 赋予执行权限: chmod +x uninstall_docker.sh
#   3. 使用 sudo 运行: sudo ./uninstall_docker.sh
#
# 警告:
#   此脚本会永久删除所有 Docker 数据，包括镜像、容器和卷。
#   在运行前，请务必备份任何你需要保留的数据！
# ==============================================================================

# 设置颜色变量，用于输出提示信息
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_NC='\033[0m' # No Color

# 脚本必须以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${COLOR_RED}错误: 此脚本必须以 root 权限运行。请使用 'sudo'。${COLOR_NC}"
  exit 1
fi

echo -e "${COLOR_YELLOW}开始执行 Docker 和 Docker Compose 卸载流程...${COLOR_NC}"
echo "----------------------------------------------------"

# --- 步骤 1: 停止所有正在运行的容器并停止 Docker 服务 ---
echo "[步骤 1/5] 停止所有正在运行的容器和 Docker 服务..."
if command -v docker &> /dev/null; then
    # 停止所有容器
    if [ -n "$(docker ps -q)" ]; then
        echo "正在停止所有容器..."
        docker stop $(docker ps -a -q)
    else
        echo "没有正在运行的容器。"
    fi
else
    echo "未找到 Docker 命令，跳过停止容器步骤。"
fi

# 停止 Docker 服务
if command -v systemctl &> /dev/null; then
    echo "正在停止 Docker 服务..."
    systemctl stop docker.service
    systemctl stop docker.socket
    systemctl stop containerd.service
    systemctl disable docker.service
    systemctl disable containerd.service
else
    echo "未找到 systemctl 命令，跳过停止服务步骤。"
fi
echo -e "${COLOR_GREEN}完成。${COLOR_NC}\n"

# --- 步骤 2: 卸载 Docker 和 Docker Compose 相关的软件包 ---
echo "[步骤 2/5] 卸载 Docker 和 Docker Compose 相关的软件包..."

# 检测包管理器
if command -v apt-get &> /dev/null; then
    echo "检测到 apt 包管理器 (Debian/Ubuntu)..."
    apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras docker-compose
    apt-get autoremove -y --purge
    echo "使用 apt 卸载软件包完成。"
elif command -v dnf &> /dev/null; then
    echo "检测到 dnf 包管理器 (CentOS/RHEL/Fedora)..."
    dnf remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
    echo "使用 dnf 卸载软件包完成。"
elif command -v yum &> /dev/null; then
    echo "检测到 yum 包管理器 (CentOS/RHEL)..."
    yum remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
    echo "使用 yum 卸载软件包完成。"
else
    echo -e "${COLOR_RED}错误: 未能识别系统的包管理器 (apt, dnf, yum)。请手动卸载软件包。${COLOR_NC}"
    exit 1
fi
echo -e "${COLOR_GREEN}完成。${COLOR_NC}\n"

# --- 步骤 3: 删除所有 Docker 数据 ---
echo "[步骤 3/5] 删除所有 Docker 数据（镜像、容器、卷等）..."

# 定义 Docker 数据目录
DOCKER_DATA_DIR="/var/lib/docker"
CONTAINERD_DATA_DIR="/var/lib/containerd"

echo -e "${COLOR_RED}警告: 下一步将永久删除所有 Docker 数据！${COLOR_NC}"
echo -e "${COLOR_YELLOW}这些数据包括：所有镜像、容器、命名卷和自定义网络配置。${COLOR_NC}"
echo "目标目录: ${DOCKER_DATA_DIR} 和 ${CONTAINERD_DATA_DIR}"
echo ""

# 关键步骤：请求用户最终确认
read -p "你确定要删除所有 Docker 数据吗？此操作无法撤销！(输入 'yes' 继续): " CONFIRMATION

if [ "$CONFIRMATION" == "yes" ]; then
    echo "正在删除 Docker 数据目录..."
    rm -rf "$DOCKER_DATA_DIR"
    rm -rf "$CONTAINERD_DATA_DIR"
    echo -e "${COLOR_GREEN}Docker 数据已成功删除。${COLOR_NC}"
else
    echo -e "${COLOR_YELLOW}操作已取消。Docker 数据目录未被删除。${COLOR_NC}"
fi
echo ""

# --- 步骤 4: 清理其他残留配置文件和二进制文件 ---
echo "[步骤 4/5] 清理其他残留的配置文件和二进制文件..."
rm -rf /etc/docker
rm -f /etc/apparmor.d/docker
rm -rf /run/docker

echo "正在检查并删除手动安装的 Docker Compose..."
rm -f /usr/local/bin/docker-compose
rm -f /usr/bin/docker-compose

echo -e "${COLOR_GREEN}完成。${COLOR_NC}\n"

# --- 步骤 5: 验证卸载 ---
echo "[步骤 5/5] 验证卸载结果..."
VERIFICATION_FAILED=false

if command -v docker &> /dev/null; then
    echo -e "${COLOR_RED}验证失败: 'docker' 命令仍然存在。${COLOR_NC}"
    VERIFICATION_FAILED=true
fi

if command -v docker-compose &> /dev/null; then
    echo -e "${COLOR_RED}验证失败: 'docker-compose' 命令仍然存在。${COLOR_NC}"
    VERIFICATION_FAILED=true
fi

if [ "$VERIFICATION_FAILED" = false ]; then
    echo -e "${COLOR_GREEN}验证成功: 'docker' 和 'docker-compose' 命令均已不存在。${COLOR_NC}"
fi

echo "----------------------------------------------------"
echo -e "${COLOR_GREEN}Docker 和 Docker Compose 卸载流程执行完毕！${COLOR_NC}"
echo "建议重启系统以确保所有变更生效。"

exit 0

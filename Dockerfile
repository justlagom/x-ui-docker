# ----------------------------------------------------
# Base Image and Tools Setup
# ----------------------------------------------------
# 使用轻量级 Alpine 基础镜像
FROM alpine:latest

# 定义目标架构参数，由 GitHub Actions 传入 (例如 amd64 或 arm64)
ARG TARGETARCH

# 安装必要的工具，bash 用于确保 RUN 命令的 shell 脚本稳定执行
RUN apk update && apk add --no-cache net-tools curl bash

# 设定 X-UI 程序的安装路径
WORKDIR /usr/local/x-ui

# ----------------------------------------------------
# 1. Project Packaging
# ----------------------------------------------------
# 复制所有文件（项目完整打包）到工作目录
COPY . .

# ----------------------------------------------------
# 2. Architecture Selection and Renaming
# ----------------------------------------------------
# 根据 TARGETARCH 变量，选择正确的二进制文件并重命名为 'x-ui'
RUN target_file="" && \
    # 确定目标文件名称
    if [ "$TARGETARCH" = "amd64" ]; then \
        target_file="xuiwpph_amd64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        target_file="xuiwpph_arm64"; \
    else \
        echo "Error: Unsupported architecture $TARGETARCH."; exit 1; \
    fi && \
    \
    echo "--- Architecture Setup ---" && \
    echo "Target Architecture: $TARGETARCH. Expected file: $target_file" && \
    \
    # 检查目标文件是否存在 (防止 'mv' 失败的关键步骤)
    if [ ! -f "$target_file" ]; then \
        echo "Error: Required binary '$target_file' not found. Please ensure the file is committed to the repository."; exit 1; \
    fi && \
    \
    # 重命名特定的二进制文件为通用的 'x-ui'
    echo "Renaming $target_file to x-ui..."; \
    mv "$target_file" x-ui

# 3. 赋予可执行权限
RUN chmod +x x-ui

# ----------------------------------------------------
# 4. X-UI Configuration and Entrypoint
# ----------------------------------------------------

# 设置数据库文件路径，实现数据持久化
ENV XUI_DB_FILE="/etc/x-ui/x-ui.db"
RUN mkdir -p /etc/x-ui

# 暴露 X-UI 面板默认端口
EXPOSE 54321

# 容器启动时运行 X-UI
ENTRYPOINT ["/usr/local/x-ui/x-ui"]
CMD ["start"]

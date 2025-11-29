# 建议使用 Alpine 基础镜像，体积更小
FROM alpine:latest

# 定义目标架构参数，由 GitHub Actions 传入
ARG TARGETARCH

# 安装必要的工具
RUN apk update && apk add --no-cache net-tools curl bash

# 设定 X-UI 程序的安装路径
WORKDIR /usr/local/x-ui

# 核心步骤 1: 复制所有文件
COPY . .

# 核心步骤 2: 根据 TARGETARCH 变量，将正确的二进制文件重命名为 'x-ui'
RUN echo "Target Architecture is: $TARGETARCH" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        mv xuiwpph_amd64 x-ui; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        mv xuiwpph_arm64 x-ui; \
    else \
        echo "Error: Unsupported architecture $TARGETARCH. Exiting."; exit 1; \
    fi

# 核心步骤 3: 赋予可执行权限 (针对统一命名后的文件)
RUN chmod +x x-ui

# 核心步骤 4: 复制配置和 metadata 文件 (已经通过 COPY . . 完成，但为了清晰，如果配置在子目录，仍需指定)
# 假设其他配置（ssh.yml, version, 默认分流配置）也位于 /usr/local/x-ui/

# 设置数据库文件路径
ENV XUI_DB_FILE="/etc/x-ui/x-ui.db"
RUN mkdir -p /etc/x-ui

# X-UI 面板默认端口
EXPOSE 54321

# 容器启动时运行 X-UI
ENTRYPOINT ["/usr/local/x-ui/x-ui"]
CMD ["start"]

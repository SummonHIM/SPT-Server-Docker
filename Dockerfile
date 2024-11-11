# 使用Node.js 20.11.1作为基础镜像
FROM node:20.11.1

# 设置工作目录
WORKDIR /build-env

# 安装 git 和 git-lfs
RUN apt-get update && apt-get install -y git git-lfs && git-lfs install

# 设置环境变量，用于指定分支或 commit hash
ARG BRANCH=master

# 克隆仓库并获取完整历史记录
RUN git clone https://dev.sp-tarkov.com/SPT/Server.git SPT-Server

# 切换到工作目录
WORKDIR /build-env/SPT-Server

# 切换到指定分支或 commit hash
RUN git fetch && git checkout $BRANCH

# 拉取 LFS 文件
RUN git lfs pull

# 安装依赖并构建项目
WORKDIR /build-env/SPT-Server/project
RUN npm install && npm run build:release

# 将构建结果复制到新的镜像
FROM debian:bullseye-slim
WORKDIR /app

# 复制构建产物到 /app
COPY --from=0 /build-env/SPT-Server/project/build/ /app/

# 赋予 SPT.Server.exe 可执行权限
RUN chmod +x /app/SPT.Server.exe

# 设置运行环境变量
ENV PATH="/app:${PATH}"

# 暴露服务端口 6969
EXPOSE 6969

# 运行服务
CMD ["/app/SPT.Server.exe"]

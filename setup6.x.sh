#!/bin/bash

echo "
  ____             __          _       _                
 / ___|    __ _   / _|   ___  | |     (_)  _ __     ___ 
 \___ \   / _\` | | |_   / _ \ | |     | | | '_ \   / _ \\
  ___) | | (_| | |  _| |  __/ | |___  | | | | | | |  __/
 |____/   \__,_| |_|    \___| |_____| |_| |_| |_|  \___|
"

export STREAM=${STREAM:-0}
export CDN=${CDN:-1}

qrcode() {
    echo "█████████████████████████████████████████"
    echo "█████████████████████████████████████████"
    echo "████ ▄▄▄▄▄ █▀ █▀▀██▀▄▀▀▄▀▄▀▄██ ▄▄▄▄▄ ████"
    echo "████ █   █ █▀ ▄ █▀▄▄▀▀ ▄█▄  ▀█ █   █ ████"
    echo "████ █▄▄▄█ █▀█ █▄█▄▀▀▄▀▄ ▀▀▄▄█ █▄▄▄█ ████"
    echo "████▄▄▄▄▄▄▄█▄█▄█ █▄▀ █ ▀▄▀ █▄█▄▄▄▄▄▄▄████"
    echo "████▄ ▄▄ █▄▄  ▄█▄▄▄▄▀▄▀▀▄██ ▄▄▀▄█▄▀ ▀████"
    echo "████▄ ▄▀▄ ▄▀▄ ▀ ▄█▀ ▀▄ █▀▀ ▀█▀▄██▄▀▄█████"
    echo "█████ ▀▄█ ▄ ▄▄▀▄▀▀█▄▀▄▄▀▄▀▄ ▄ ▀▄▄▄█▀▀████"
    echo "████ █▀▄▀ ▄▀▄▄▀█▀ ▄▄ █▄█▀▀▄▀▀█▄█▄█▀▄█████"
    echo "████ █ ▀  ▄▀▀ ██▄█▄▄▄▄▄▀▄▀▀▀▄▄▀█▄▀█ ▀████"
    echo "████ █ ▀▄ ▄██▀▀ ▄█▀ ▀███▄  ▀▄▀▄▄ ▄▀▄█████"
    echo "████▀▄▄█  ▄▀▄▀ ▄▀▀▀▄▀▄▀ ▄▀▄  ▄▀ ▄▀█ ▀████"
    echo "████ █ █ █▄▀ █▄█▀ ▄▄███▀▀▀▄█▀▄ ▀  ▀▄█████"
    echo "████▄███▄█▄▄▀▄ █▄█▄▄▄▄▀▀▄█▀▀ ▄▄▄  ▀█ ████"
    echo "████ ▄▄▄▄▄ █▄▀█ ▄█▀▄ █▀█▄ ▀  █▄█  ▀▄▀████"
    echo "████ █   █ █  █▄▀▀▀▄▄▄▀▀▀▀▀▀ ▄▄  ▀█  ████"
    echo "████ █▄▄▄█ █  ▀█▀ ▄▄▄▄ ▀█ ▀▀▄▀ ▀▀ ▀██████"
    echo "████▄▄▄▄▄▄▄█▄▄██▄█▄▄█▄██▄██▄▄█▄▄█▄█▄█████"
    echo "█████████████████████████████████████████"
    echo "█████████████████████████████████████████"

    echo
    echo "微信扫描上方二维码加入雷池项目讨论组"
}

command_exists() {
	command -v "$1" 2>&1
}

check_container_health() {
    local container_name=$1
    local max_retry=30
    local retry=0
    local health_status="unhealthy"
    echo "Waiting for $container_name to be healthy"
    while [[ "$health_status" == "unhealthy" && $retry -lt $max_retry ]]; do
        health_status=$(docker inspect --format='{{.State.Health.Status}}' $container_name 2>/dev/null || echo 'unhealthy')
        sleep 1
        retry=$((retry+1))
    done
    if [[ "$health_status" == "unhealthy" ]]; then
        abort "Container $container_name is unhealthy"
    fi
    echo "Container $container_name is healthy"
}

space_left() {
    dir="$1"
    while [ ! -d "$dir" ]; do
        dir=`dirname "$dir"`;
    done
    echo `df -h "$dir" --output='avail' | tail -n 1`
}

start_docker() {
    systemctl start docker && systemctl enable docker
}

confirm() {
    echo -e -n "\033[34m[SafeLine] $* \033[1;36m(Y/n)\033[0m"
    read -n 1 -s opt

    [[ "$opt" == $'\n' ]] || echo

    case "$opt" in
        'y' | 'Y' ) return 0;;
        'n' | 'N' ) return 1;;
        *) confirm "$1";;
    esac
}

info() {
    echo -e "\033[37m[SafeLine] $*\033[0m"
}

warning() {
    echo -e "\033[33m[SafeLine] $*\033[0m"
}

abort() {
    qrcode
    echo -e "\033[31m[SafeLine] $*\033[0m"
    exit 1
}

trap 'onexit' INT
onexit() {
    echo
    abort "用户手动结束安装"
}

# CPU ssse3 指令集检查
support_ssse3=1

cat /proc/cpuinfo | grep ssse3 > /dev/null 2>&1
if [ $support_ssse3 -eq "0" -a $? -ne "0" ]; then
    abort "雷池需要运行在支持 ssse3 指令集的 CPU 上，虚拟机请自行配置开启 CPU ssse3 指令集支持"
fi

safeline_path='/data/safeline'

if [ -z "$BASH" ]; then
    abort "请用 bash 执行本脚本，请参考最新的官方技术文档 https://waf-ce.chaitin.cn/"
fi

if [ ! -t 0 ]; then
    abort "STDIN 不是标准的输入设备，请参考最新的官方技术文档 https://waf-ce.chaitin.cn/"
fi

if [ "$#" -ne "0" ]; then
    abort "当前脚本无需任何参数，请参考最新的官方技术文档 https://waf-ce.chaitin.cn/"
fi

if [ "$EUID" -ne "0" ]; then
    abort "请以 root 权限运行"
fi
info "脚本调用方式确认正常"

if [ -z `command_exists docker` ]; then
    warning "缺少 Docker 环境"
    if confirm "是否需要自动安装 Docker"; then
        curl -sSLk https://get.docker.com/ | bash
        if [ $? -ne "0" ]; then
            abort "Docker 安装失败"
        fi
        info "Docker 安装完成"
    else
        abort "中止安装"
    fi
fi
info "发现 Docker 环境: '`command -v docker`'"

start_docker
docker version > /dev/null 2>&1
if [ $? -ne "0" ]; then
    abort "Docker 服务工作异常"
fi
info "Docker 工作状态正常"

compose_command="docker compose"
if $compose_command version; then
    info "发现 Docker Compose Plugin"
else
    warning "未发现 Docker Compose Plugin"
    compose_command="docker-compose"
    if [ -z `command_exists "docker-compose"` ]; then
        warning "未发现 docker-compose 组件"
        if confirm "是否需要自动安装 Docker Compose Plugin"; then
            curl -sSLk https://get.docker.com/ | bash
            if [ $? -ne "0" ]; then
                abort "Docker Compose Plugin 安装失败"
            fi
            info "Docker Compose Plugin 安装完成"
            compose_command="docker compose"
        else
            abort "中止安装"
        fi
    else
        info "发现 docker-compose 组件: '`command -v docker-compose`'"
    fi
fi

while true; do
    echo -e -n "\033[34m[SafeLine] 雷池安装目录 (留空则为 '$safeline_path'): \033[0m"
    read input_path
    [[ -z "$input_path" ]] && input_path=$safeline_path

    if [[ ! $input_path == /* ]]; then
        warning "'$input_path' 不是合法的绝对路径"
        continue
    fi

  

    safeline_path=$input_path

    if confirm "目录 '$safeline_path' 当前剩余存储空间为 `space_left \"$safeline_path\"` ，雷池至少需要 5G，是否确定"; then
        break
    fi
done


cd "$safeline_path"

curl "https://waf-ce.chaitin.cn/release/latest/compose.yaml" -sSLk -o docker-compose.yaml

if [ $? -ne "0" ]; then
    abort "下载 compose.yaml 脚本失败"
fi
info "下载 compose.yaml 脚本成功"

touch ".env"
if [ $? -ne "0" ]; then
    abort "创建 .env 脚本失败"
fi
info "创建 .env 脚本成功"

echo "SAFELINE_DIR=$safeline_path" >> .env
mkdir -p $safeline_path/resources/postgres/data
mkdir -p $safeline_path/resources/luigi
mkdir -p $safeline_path/resources/mgt
mkdir -p $safeline_path/resources/mario
mkdir -p $safeline_path/logs/mario
mkdir -p $safeline_path/resources/detector
mkdir -p $safeline_path/logs/detector
mkdir -p $safeline_path/logs/nginx
mkdir -p $safeline_path/logs/chaos
mkdir -p $safeline_path/resources/chaos
mkdir -p $safeline_path/resources/nginx
mkdir -p $safeline_path/resources/detector
mkdir -p $safeline_path/resources/cache

if [ $STREAM -eq 1 ]; then
    echo "IMAGE_TAG=latest-stream" >>".env"
else
    echo "IMAGE_TAG=latest" >>".env"
fi

echo "MGT_PORT=9443" >> .env
echo "POSTGRES_PASSWORD=$(LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 32)" >> .env
echo "SUBNET_PREFIX=172.22.222" >> .env

if [ $CDN -eq 0 ]; then
    echo "IMAGE_PREFIX=chaitin" >>".env"
else
    echo "IMAGE_PREFIX=swr.cn-east-3.myhuaweicloud.com/chaitin-safeline" >>".env"
fi

info "即将开始下载 Docker 镜像"

$compose_command up -d

if [ $? -ne "0" ]; then
    abort "启动 Docker 容器失败"
fi

qrcode

check_container_health safeline-pg
check_container_health safeline-mgt
docker exec safeline-mgt /app/mgt-cli reset-admin --once
echo "host    all             all             all                     trust" => $safeline_path/resources/postgres/data/pg_hba.conf
warning "雷池 WAF 社区版安装成功，请访问以下地址访问控制台"
warning "https://0.0.0.0:9443/"


#!/bin/bash
# 文件位置：$HOME/Setup.sh

github_repo="github.com"               # 默认 github 仓库域名
github_raw="raw.githubusercontent.com" # 默认 github raw 域名

# 设置 github 镜像域名
function github_proxy_set() {
  while true; do
    read -rp "是否启用 Github 国内加速? [Y/n] " input
    case $input in
    [yY])
      # git config --global url."https://hub.fastgit.xyz/".insteadOf https://github.com/
      github_repo="mirror.ghproxy.com/github.com"
      github_raw="mirror.ghproxy.com/raw.githubusercontent.com"
      # wget https://${github_download}/dotnetcore/FastGithub/releases/latest/download/fastgithub_linux-x64.zip -NP ~ &&
      #   unzip ~/fastgithub_linux-x64.zip
      # sudo ~/fastgithub_linux-x64/fastgithub start &&
      #   export http_proxy=127.0.0.1:38457
      # export https_proxy=127.0.0.1:38457
      # github_raw="raw.fastgit.org"
      break
      ;;

    [nN])
      # git config --global --remove-section url."https://hub.fastgit.xyz/"
      github_repo="github.com"
      github_raw="raw.githubusercontent.com"
      break
      ;;

    *)
      echo "错误选项：$REPLY"
      ;;
    esac
  done
}

# APT 软件更新安装
function app_install() {
  echo
  echo "---------- 应用安装 ----------"
  echo
  sudo apt update -y &&
    sudo apt upgrade -y &&
    sudo apt install zsh git vim unzip bc curl wget -y &&
    if ! btm --version; then
      wget https://$github_repo/ClementTsang/bottom/releases/download/0.6.8/bottom_0.6.8_amd64.deb -NP ~ &&
        sudo dpkg -i ~/bottom_0.6.8_amd64.deb
    else
      echo "已安装 bottom"
    fi

  if ! neofetch --version; then
    if ! sudo apt install neofetch -y; then
      git clone https://$github_repo/dylanaraps/neofetch && # 编译安装
        make -C ~/neofetch install
    fi
  else
    echo "已安装 neofetch"
  fi

  neofetch
  read -rp "按回车键继续"
}

# 配置终端
function term_config() {
  echo
  echo "---------- 配置终端 ----------"
  echo
  chsh -s "$(which zsh)" &&                                                                                                                      # 设置 zsh 为默认 shell
    RUNZSH=no sh -c "$(curl -fsSL https://$github_raw/ohmyzsh/ohmyzsh/master/tools/install.sh)" &&                                               # 使用 oh-my-zsh 官方一键安装脚本
    git clone https://$github_repo/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions &&             # 下载 zsh 自动建议插件
    git clone https://$github_repo/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting && # 下载 zsh 语法高亮插件
    sed -i 's/^plugins=(/plugins=(\nzsh-autosuggestions\nzsh-syntax-highlighting\n/g' ~/.zshrc &&                                                # 启用 zsh 插件
    sudo wget https://$github_repo/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh &&           # 下载 oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh &&
    mkdir ~/.poshthemes &&
    wget https://$github_repo/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip && # 下载 oh-my-posh 主题文件
    unzip ~/.poshthemes/themes.zip -d ~/.poshthemes &&
    chmod u+rw ~/.poshthemes/*.omp.* &&
    rm ~/.poshthemes/themes.zip &&
    sed -i '$a\eval "$(oh-my-posh --init --shell zsh --config ~/.poshthemes/craver.omp.json)"' ~/.zshrc # 每次进入 zsh 时，自动打开 oh-my-posh 主题

  wget https://$github_raw/Tsanfer/Setup_server/main/.vimrc -NP ~ # 下载 vim 自定义配置文件
}

# 设置 swap 内存
function swap_set() {
  free -h # 显示当前 swap 使用情况

  while true; do
    read -rp "配置 swap 功能 (Y:覆盖/n:关闭/q:跳过): " input
    case $input in
    [yY])
      if swapoff -a; then                             # 关闭所有 swap 内存
        awk '/swap/ {print $1}' /etc/fstab | xargs rm # 删除原有 swap 文件
        sed -i '/swap/d' /etc/fstab                   # 删除原有 swap 在 /etc/fstab 中的配置信息
        read -rp "设置 swap 大小 (单位 MB): " swap_size
        ((swap_size *= 1024))                                   # 从 B 转换为 KB
        dd if=/dev/zero of=/var/swap bs=1024 count="$swap_size" # 生成新的 swap 文件（单位：Byte），大小 = bs*count
        chmod 600 /var/swap                                     # 更改 swap 文件权限，防止任意修改
        mkswap /var/swap                                        # 使用新的 swap 文件
        read -rp "设置内存剩余小于百分之多少时，才启用 swap (单位 %): " swap_enable_threshold
        sed -i "s/^vm.swappiness.*/vm.swappiness=$swap_enable_threshold/g" /etc/sysctl.conf # 替换旧有的阈值
        sysctl -p                                                                           # 重新读取 swap 配置
        swapon /var/swap                                                                    # 打开 swap
        echo "/var/swap swap swap defaults 0 0" >>/etc/fstab                                # 每次开机自动运行 swap
        break
      else
        echo "释放 swap 内存失败，请尝试预留更多物理内存后重试"
      fi
      ;;

    [nN])
      if swapoff -a; then                             # 关闭所有 swap 内存
        awk '/swap/ {print $1}' /etc/fstab | xargs rm # 删除原有 swap 文件
        sed -i '/swap/d' /etc/fstab                   # 删除原有 swap 在 /etc/fstab 中的配置信息
      else
        echo "释放 swap 内存失败，请尝试预留更多物理内存后重试"
      fi
      break
      ;;

    [qQ])
      break
      ;;

    *)
      echo "错误选项：$REPLY"
      ;;
    esac
  done
}

# Docker 安装/更新
function docker_install() {
  echo
  echo "---------- 安装/更新 Docker ----------"
  echo
  release_ver=$(awk '/Ubuntu/ {print $2}' /etc/issue | awk -F. '{printf "%s.%s\n",$1,$2}') # 获得 Ubuntu 版本号（如：20.04）
  if echo "$(echo "$release_ver" | bc) >= 18.04" | bc; then                                # 如果版本符合要求
    echo "安装/更新 Docker 环境..."

    if docker -v; then
      echo "删除现有容器"
      docker rm -f "$(docker ps -q)"
    fi

    # sudo apt-get remove docker docker-engine docker.io containerd runc && \
    sudo apt-get install \
      ca-certificates \
      curl \
      gnupg \
      lsb-release -y &&                                                                                               # 预装 Docker 需要的软件
      sudo mkdir -p /etc/apt/keyrings &&                                                                              # 创建公钥文件夹
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && # 添加 Docker 官方的 GPG 密钥
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null && # 重新建立 apt 仓库
      sudo apt-get update -y &&                                                           # 更新 apt 仓库
      sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y # 安装 docker 相关软件
    echo "安装/更新 docker 环境完成!"
  else
    echo "Ubuntu 版本低于 18.04 无法安装 Docker"
  fi
}

# 从 Docker compose 部署 docker 容器
function docker_deploy() {
  echo
  echo "---------- 运行 Docker-compose ----------"
  echo
  echo "检查 Docker 状态..."
  if docker -v; then
    wget https://$github_raw/Tsanfer/Setup_server/main/docker-compose.yml -NP ~ && # 下载默认 docker compose 文件
      docker compose up -d &&                                                      # 从默认文件部署 docker 容器
      echo "构建 Docker 容器"
    docker_list=("code-server" "nginx" "pure-ftpd" "web_object_detection") # 可安装容器列表
    while true; do

      for i in "${!docker_list[@]}"; do
        echo "$i. ${docker_list[$i]}" # 显示可安装容器列表
      done

      read -r -p "选择需要安装的 Docker 容器序号 (q:退出): " input
      case $input in
      [0]) # code-server: 在线 Web IDE
        read -rsp "设置密码: " password
        read -rsp "设置 sudo 密码: " sudo_password
        echo "PASSWORD=$password" >~/"${docker_list[$input]}".env # 将输入的密码，保存至本地环境变量文件
        echo "SUDO_PASSWORD=$sudo_password" >>~/"${docker_list[$input]}".env
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -NP ~ &&           # 下载选择的 docker compose 文件
          docker compose -f ~/"${docker_list[$input]}".yml --env-file ~/"${docker_list[$input]}".env up -d # 使用指定的 docker compose 文件和环境变量文件，构建 docker 容器
        ;;

      [1]) # nginx: Web 服务器
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -NP ~ &&
          docker compose -f ~/"${docker_list[$input]}".yml up -d # 使用指定的 docker compose 文件，构建 docker 容器
        ;;

      [2]) # pure-ftpd: FTP 服务器
        read -rp "设置 ftp 用户名: " ftp_username
        read -rsp "设置 ftp 密码: " ftp_password
        echo "FTP_USER_NAME=$ftp_username" >~/"${docker_list[$input]}".env
        echo "FTP_USER_PASS=$ftp_password" >>~/"${docker_list[$input]}".env
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -NP ~ &&
          docker compose -f ~/"${docker_list[$input]}".yml --env-file ~/"${docker_list[$input]}".env up -d
        ;;

      [3]) # web_object_detection: 在线 web 目标识别
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -NP ~ &&
          docker compose -f ~/"${docker_list[$input]}".yml up -d
        ;;

      [qQ])
        break
        ;;

      *)
        echo "错误选项：$REPLY"
        ;;
      esac
    done
    docker images -a # 显示当前所有 docker 镜像
    docker ps -a     # 显示当前所有 docker 容器
  else
    echo "Docker 未安装!"
  fi
}

# 清理 APT 空间
function apt_clean() {
  while true; do
    read -rp "是否清理 APT 空间？(Y/n): " input
    case $input in
    [yY])
      sudo apt clean -y &&     # 删除存储在本地的软件安装包
        sudo apt purge -y &&   # 删除软件配置文件
        sudo apt autoremove -y # 删除不再需要的依赖软件包
      break
      ;;

    [nN])
      break
      ;;

    *)
      echo "错误选项：$REPLY"
      ;;
    esac
  done
}

# 重启系统
function sys_reboot() {
  while true; do
    read -rp "是否重启系统？(Y/n): " input
    case $input in
    [yY])
      reboot # 重启系统
      break
      ;;

    [nN])
      break
      ;;

    *)
      echo "错误选项：$REPLY"
      ;;
    esac
  done
}

github_proxy_set

if grep "Ubuntu" /etc/issue; then # 判断系统发行版是否为 Ubuntu
  app_install &&
    term_config &&
    swap_set &&
    docker_install &&
    docker_deploy &&
    apt_clean &&
    sys_reboot
  echo "Done!!!"
  zsh # 进入新终端
else
  echo "linux 系统不是 Ubuntu"
fi

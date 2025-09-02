#!/bin/bash
# 文件位置：$HOME/Setup.sh

github_repo="github.com"               # 默认 github 仓库域名
github_release="github.com" # 默认 github release 域名
github_raw="raw.githubusercontent.com" # 默认 github raw 域名

script_list=("app_update_init" "swap_set" "vps_reviews" "term_config"  "app_install" "app_remove" "docker_init" "docker_install" "docker_update" "docker_remove" "apt_clean" "sys_reboot")                                                                           # 脚本列表
script_list_info=("APT 软件更新、默认软件安装" "设置 swap 内存" "服务器测试" "配置终端" "自选软件安装" "自选软件卸载" "安装，更新 Docker" "从 Docker compose 部署 docker 容器" "更新 docker 镜像和容器" "删除 docker 镜像和容器" "清理 APT 空间" "重启系统")                  # 脚本列表说明
docker_list=("code-server" "nginx" "pure-ftpd" "web_object_detection" "zfile" "subconverter" "sub-web" "mdserver-web" "qinglong" "webdav-client" "watchtower" "jsxm")                                                                                 # 可安装容器列表
docker_list_info=("在线 Web IDE" "Web 服务器" "FTP 服务器" "在线 web 目标识别" "在线云盘" "订阅转换后端" "订阅转换前端" "一款简单Linux面板服务" "定时任务管理面板" "Webdav 客户端，同步映射到宿主文件系统" "自动化更新 Docker 镜像和容器" "Web 在线 xm 音乐播放器") # 可安装容器列表说明
app_list=("mw" "bt" "1pctl" "kubesphere")                                                                                                                                                                                                             # 自选软件列表
app_list_info=("一款简单Linux面板服务" "aaPanel面板（宝塔国外版）" "现代化、开源的 Linux 服务器运维管理面板" "在 Kubernetes 之上构建的面向云原生应用的分布式操作系统")                                                                                          # 自选软件列表说明

# 设置 github 镜像域名
function github_proxy_set() {
  while true; do
    read -rp "是否启用 Github 国内加速? [Y/n] " input
    case $input in
    [yY]) # 使用国内镜像域名
      # git config --global url."https://hub.fastgit.xyz/".insteadOf https://github.com/
      # github_repo="ghproxy.com/https://github.com"
      # github_raw="ghproxy.com/https://raw.githubusercontent.com"
      # github_repo="githubfast.com"
      github_repo="gh-proxy.com/github.com"
      github_release="gh-proxy.com/github.com"
      #github_release="get-github.hexj.org/download"
      github_raw="gh-proxy.com/raw.githubusercontent.com"

      # github_raw="ghfast.top/https://raw.githubusercontent.com"
      # github_raw="raw.gitmirror.com"
      # github_raw="raw.staticdn.net"
      # wget https://${github_download}/dotnetcore/FastGithub/releases/latest/download/fastgithub_linux-x64.zip -P ~ &&
      #   unzip ~/fastgithub_linux-x64.zip
      # sudo ~/fastgithub_linux-x64/fastgithub start &&
      #   export http_proxy=127.0.0.1:38457
      # export https_proxy=127.0.0.1:38457
      # github_raw="raw.fastgit.org"
      break
      ;;

    [nN]) # 使用原始域名
      # git config --global --remove-section url."https://hub.fastgit.xyz/"
      github_repo="github.com"
      github_release="github.com" # 默认 github release 域名
      github_raw="raw.githubusercontent.com"
      break
      ;;

    *) echo "错误选项：$REPLY" ;;
    esac
  done
}

# APT 软件更新、默认软件安装
function app_update_init() {
  echo
  echo "---------- APT 软件更新、默认软件安装 ----------"
  echo
  read -rp "是否使用 LinuxMirrors 脚本，更换国内软件源? [Y/n] " input
  while true; do
    case $input in
    [yY])
      # 使用脚本 LinuxMirrors 官方地址：https://gitee.com/SuperManito/LinuxMirrors
      # read -rsp "输入 root 密码: " sudo_password
      # echo $sudo_password | sudo bash -c "$(curl -fsSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh)"
      # sudo bash -c "$(curl -fsSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh)"
      if command -v curl >/dev/null 2>&1; then
          sudo bash <(curl -sSL https://linuxmirrors.cn/main.sh)
      elif command -v wget >/dev/null 2>&1; then
          sudo wget -qO- https://linuxmirrors.cn/main.sh | bash
      else
          echo "请先安装 curl 或 wget" >&2
          exit 1
      fi
      break
      ;;

    [nN])
      break
      ;;

    *) echo "错误选项：$REPLY" ;;
    esac
  done
  sudo apt -y update || apt -y update   # 更新软件列表
  sudo apt -y upgrade || apt -y upgrade # 更新所有软件
  # 默认安装：
  #   sudo - 系统管理指令
  #   zsh - 命令行界面
  #   git - 版本控制工具
  #   vim - 文本编辑器
  #   unzip - 解压缩zip文件
  #   bc - 计算器
  #   curl - 网络文件下载
  #   wget - 网络文件下载
  #   rsync - 文件同步
  #   bottom - 图形化系统监控
  #   fastfetch - 系统信息工具
  apt -y install sudo
  sudo apt -y install curl wget zsh git vim unzip bc rsync jq

  if ! type btm >/dev/null 2>&1; then
    # 如果没有安装 bottom
    # 从官方仓库下载安装包
    wget https://$github_release/ClementTsang/bottom/releases/download/0.10.2/bottom_0.10.2-1_amd64.deb -P ~
    # 使用 Debian 软件包管理器，安装 bottom
    sudo dpkg -i ~/bottom_0.10.2-1_amd64.deb

    # ---------- 2. 设置变量 ----------
    CONF_DIR="$HOME/.config/bottom"
    CONF_FILE="$CONF_DIR/bottom.toml"
    FLAGS=(
        "enable_cache_memory = true"
        "network_use_bytes   = true"
    )
    
    # ---------- 3. 创建目录并写配置文件 ----------
    mkdir -p "$CONF_DIR"
    
    {
        echo "[flags]"
        printf "%s\n" "${FLAGS[@]}"
    } > "$CONF_FILE"
    
    echo "✅ 已写入配置到 $CONF_FILE"
    echo "🚀 现在重新运行 'btm' 即可看到效果！"

    # # 开启 bottom 的 cache_memory 显示
    # if [ -e ~/.config/bottom/bottom.toml ]; then
    #   sed -i "s/^.*enable_cache_memory.*/enable_cache_memory = true/g" ~/.config/bottom/bottom.toml
    # else
    #   mkdir -p ~/.config/bottom
    #   echo "enable_cache_memory = true" > ~/.config/bottom/bottom.toml
    # fi

    # echo "alias btm='btm --enable_cache_memory'" >> ~/.bashrc
    # echo "alias btm='btm --enable_cache_memory'" >> ~/.zshrc
    source ~/.bashrc

  else
    echo "已安装 bottom"
  fi

  # if ! type neofetch >/dev/null 2>&1; then
  #   if ! sudo apt install neofetch -y; then
  #     git clone https://$github_repo/dylanaraps/neofetch
  #     sudo make -C ~/neofetch install # 手动从 makefile 编译安装
  #   fi
  # else
  #   echo "已安装 neofetch"
  # fi

  if ! type fastfetch >/dev/null 2>&1; then
    if ! sudo apt -y install fastfetch; then
      FASTFETCH_VERSION="2.48.1"
      wget https://$github_repo/fastfetch-cli/fastfetch/releases/download/${FASTFETCH_VERSION}/fastfetch-linux-amd64.deb
      sudo dpkg -i fastfetch-linux-amd64.deb  # 安装
      # sudo apt-get install -f  # 修复依赖（如有）
    fi
  else
    echo "已安装 fastfetch"
  fi

  # 下载 vim 自定义配置文件
  if [[ -f "$HOME/.vimrc" ]]; then
      echo "[提示] ~/.vimrc 已存在，跳过下载。"
  else
      echo "[下载] 正在拉取 Vim 配置文件 → $HOME/.vimrc ..."
      wget  "https://$github_raw/Tsanfer/Setup_server/main/.vimrc" -O "$HOME/.vimrc" \
        && echo "[完成] Vim 配置文件已保存。" \
        || echo "[失败] 下载出错，请检查网络或地址！"
  fi

  fastfetch -s \
    title:os:kernel:host:board:bios:bootmgr:uptime:packages:shell:cpu:cpucache:gpu:opengl:opencl:vulkan:memory:physicalmemory:swap:disk:physicaldisk:btrfs:zpool:gamepad:display:wifi:localip:publicip:bluetoothradio:battery:poweradapter:loadavg:processes:dateTime:locale:camera:tpm:editor:command:colors:break \
    --cpu-temp --gpu-temp --physicaldisk-temp --battery-temp

  read -rp "按回车键继续"
}

# 设置 swap 内存
function swap_set() {
  echo
  echo "---------- 设置 swap 内存 ----------"
  echo
  free -h # 显示当前 swap 使用情况

  while true; do
    read -rp "配置 swap 功能 (Y:覆盖/n:关闭/q:跳过): " input
    case $input in
    [yY])
      if swapoff -a; then                             # 关闭所有 swap 内存
        awk '/swap/ {print $1}' /etc/fstab | xargs rm # 删除原有 swap 文件
        sed -i '/swap/d' /etc/fstab                   # 删除原有 swap 在 /etc/fstab 中的配置信息
        read -rp "设置 swap 大小 (单位 MB): " swap_size
        dd if=/dev/zero of=/var/swap bs=1M count="$swap_size" # 生成新的 swap 文件（原单位：Byte），大小 = bs*count
        chmod 600 /var/swap                                   # 更改 swap 文件权限，防止任意修改
        mkswap /var/swap                                      # 使用新的 swap 文件
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

    [qQ]) break ;;
    *) echo "错误选项：$REPLY" ;;
    esac
  done
}

# 服务器测试
function vps_reviews() {
  echo
  echo "---------- VPS 融合怪脚本服务器测试 ----------"
  echo

  # 判断 goecs 命令是否存在
  if command -v goecs &> /dev/null; then
      echo "goecs 命令已安装，路径为：$(command -v goecs)"
  else
      echo "goecs 命令未安装，安装 goecs"
      # 下载脚本
      curl -L https://cnb.cool/oneclickvirt/ecs/-/git/raw/main/goecs.sh -o goecs.sh && chmod +x goecs.sh
      # 更新包管理器（可选择）并安装环境
      export noninteractive=true && ./goecs.sh env
      # 安装 goecs
      ./goecs.sh install
      # 升级 goecs
      # ./goecs.sh upgrade
      # 卸载 goecs
      # ./goecs.sh uninstall
  fi
  goecs -diskmc=true
  read -rp "按回车键继续"
}

# 配置终端
function term_config() {
  echo
  echo "---------- 配置终端 ----------"
  echo

  if [ ! -d ~/.oh-my-zsh ]; then
    echo "oh-my-zsh 未安装"
    rm -rf ~/.oh-my-zsh ~/.zshrc
    # RUNZSH=no sh -c "$(curl -fsSL https://$github_raw/ohmyzsh/ohmyzsh/master/tools/install.sh)" &&                                             # 使用 oh-my-zsh 官方一键安装脚本（安装完成后，不自动运行）
    # RUNZSH=no sh -c "$(curl -fsSL https://install.ohmyz.sh/)"
    git clone https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git
    cd ohmyzsh/tools
    RUNZSH=no REMOTE=https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git sh install.sh
    cd
    # # 安装 zsh 和设置 zsh 为默认shell
    sudo apt-get update -y
    sudo apt-get install -y zsh
    chsh -s $(which zsh)


    # git clone https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh &&
    # cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc &&

    # RUNZSH=no sh -c "$(wget -O- https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

    git clone https://$github_repo/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions &&             # 下载 zsh 自动建议插件
    git clone https://$github_repo/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && # 下载 zsh 语法高亮插件
    sed -i 's/^plugins=(/plugins=(\nzsh-autosuggestions\nzsh-syntax-highlighting\n/g' ~/.zshrc                                                 # 加载插件到 zsh 启动配置文件

    sed -i 's/^#\s*DISABLE_MAGIC_FUNCTIONS="true"$/DISABLE_MAGIC_FUNCTIONS="true"/' ~/.zshrc                                                   # 防止粘贴网址和其他文本时出现混乱

    if ! oh-my-posh --version; then
      echo "oh-my-posh 未安装"
      while true; do
        read -rp "是否安装 oh-my-posh? [Y/n] " input
        case $input in
        [yY])
          if [ "$github_repo" = "github.com" ]; then
            mkdir ~/.local
            curl -s https://ohmyposh.dev/install.sh | bash -s
            echo 'export PATH=$PATH:$HOME/.local/bin' >>~/.zshrc
          else
            echo "国内安装方式，安装 oh-my-posh 可能无法成功，尝试安装"
            sudo wget https://$github_release/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh && # 下载 oh-my-posh
              sudo chmod +x /usr/local/bin/oh-my-posh
          fi
          mkdir ~/.poshthemes &&
          wget https://$github_release/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip && # 下载 oh-my-posh 主题文件
          unzip ~/.poshthemes/themes.zip -d ~/.poshthemes &&
          chmod u+rw ~/.poshthemes/*.omp.* &&
          rm ~/.poshthemes/themes.zip
          sed -i '$a\eval "$(oh-my-posh init zsh --config ~/.poshthemes/craver.omp.json)"' ~/.zshrc # 每次进入 zsh 时，自动打开 oh-my-posh 主题
          break
          ;;

        [nN])
          break
          ;;

        *) echo "错误选项：$REPLY" ;;
        esac
      done
    else
      while true; do
        read -rp "已安装 oh-my-posh, 是否卸载? [Y/n] " input
        case $input in
        [yY])
          rm -rf "$(which oh-my-posh)"
          rm -rf ~/.oh-my-zsh
          rm -rf  ~/.poshthemes
          break
          ;;

        [nN])
          break
          ;;

        *) echo "错误选项：$REPLY" ;;
        esac
      done
    fi
  else
    while true; do
      read -rp "已安装 oh-my-zsh, 是否卸载 oh-my-zsh 和 oh-my-posh ? [Y/n] " input
      case $input in
      [yY])
        chmod +x ~/.oh-my-zsh/tools/uninstall.sh
        ~/.oh-my-zsh/tools/uninstall.sh
        # rm -rf ~/.oh-my-zsh
        rm -rf "$(which oh-my-posh)"
        rm -rf ~/.oh-my-zsh
        rm -rf  ~/.poshthemes
        break
        ;;

      [nN])
        break
        ;;

      *) echo "错误选项：$REPLY" ;;
      esac
    done
  fi




}

# 自选软件安装
function app_install() {
  echo
  echo "---------- 自选软件安装 ----------"
  echo

  while true; do
    echo
    echo "已安装的自选软件: "
    for i in "${!app_list[@]}"; do
      case $i in

      [0]) # mdserver-web: 一款简单Linux面板服务
        if type "${app_list[$i]}" >/dev/null 2>&1; then
          echo "${app_list_info[$i]} 已安装"
        fi
        ;;

      [1]) # aaPanel: 宝塔面板国外版
        if type "${app_list[$i]}" >/dev/null 2>&1; then
          echo "${app_list_info[$i]} 已安装"
        fi
        ;;

      [2]) # 1pctl: 现代化、开源的 Linux 服务器运维管理面板
        if type "${app_list[$i]}" >/dev/null 2>&1; then
          echo "${app_list_info[$i]} 已安装"
        fi
        ;;

      esac
    done

    echo
    for i in "${!app_list_info[@]}"; do
      printf "%2s. %-20s%-s\n" "$i" "${app_list[$i]}" "${app_list_info[$i]}" # 显示自选软件列表
    done
    read -r -p "选择需要安装的软件序号 (q:退出): " input
    case $input in
    [0]) # mdserver-web: 一款简单Linux面板服务
      curl -fsSL https://$github_raw/midoks/mdserver-web/master/scripts/install.sh | bash
      ;;
    [1]) # aaPanel: 宝塔面板国外版
      if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi;bash install_panel.sh ed8484bec
      ;;
    [2]) # 1Panel: 现代化、开源的 Linux 服务器运维管理面板
      # curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && sudo bash quick_start.sh
      bash -c "$(curl -sSL https://resource.fit2cloud.com/1panel/package/v2/quick_start.sh)"
      ;;
    [3]) # KubeSphere: 在 Kubernetes 之上构建的面向云原生应用的分布式操作系统
      apt-get -y install socat conntrack ebtables ipset
      curl -sfL https://get-kk.kubesphere.io | sh -
      chmod +x kk
      ./kk create cluster --with-kubernetes v1.24.14 --container-manager containerd --with-kubesphere v3.4.0
      ;;

    [qQ]) break ;;
    *) echo "错误选项：$REPLY" ;;
    esac
  done
}

# 自选软件卸载
function app_remove() {
  echo
  echo "---------- 自选软件卸载 ----------"
  echo

  while true; do
    echo
    echo "已安装的自选软件: "
    for i in "${!app_list[@]}"; do
      case $i in

      [0]) # mdserver-web: 一款简单Linux面板服务
        if type "${app_list[$i]}" >/dev/null 2>&1; then
          echo "${app_list_info[$i]} 已安装"
        fi
        ;;

      [1]) # aaPanel: 宝塔面板国外版
        if type "${app_list[$i]}" >/dev/null 2>&1; then
          echo "${app_list_info[$i]} 已安装"
        fi
        ;;

      [2]) # 1Panel: 现代化、开源的 Linux 服务器运维管理面板
        if type "${app_list[$i]}" >/dev/null 2>&1; then
          echo "${app_list_info[$i]} 已安装"
        fi
        ;;

      esac
    done

    echo
    for i in "${!app_list_info[@]}"; do
      printf "%2s. %-20s%-s\n" "$i" "${app_list[$i]}" "${app_list_info[$i]}" # 显示自选软件列表
    done
    read -r -p "选择需要卸载的软件序号 (q:退出): " input
    case $input in
    [0]) # mdserver-web: 一款简单Linux面板服务
      wget -O uninstall.sh https://raw.githubusercontent.com/midoks/mdserver-web/master/scripts/uninstall.sh && bash uninstall.sh
      ;;
    [1]) # aaPanel: 宝塔面板国外版
      wget http://download.bt.cn/install/bt-uninstall.sh && sh bt-uninstall.sh
      ;;
    [1]) # 1Panel: 现代化、开源的 Linux 服务器运维管理面板
      1pctl uninstall
      ;;
    [qQ]) break ;;
    *) echo "错误选项：$REPLY" ;;
    esac
  done
}

# Docker 安装/更新
function docker_init() {
  echo
  echo "---------- 安装/更新 Docker ----------"
  echo

  while true; do
    read -rp "是否配置国内源安装 docker? [Y/n]" input
    case $input in
    [yY])
      # bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/DockerInstallation.sh)
      bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
      break
      ;;

    [nN])
      mkdir -p /etc/apt/sources.list.d
      curl -fsSL https://get.docker.com | sh
      break
      ;;

    *) echo "错误选项：$REPLY" ;;
    esac
  done

  # sudo apt-get remove docker docker-engine docker.io containerd runc && \
  # sudo apt-get install \
  #   ca-certificates \
  #   curl \
  #   gnupg                                                                                                # 预装 Docker 需要的软件
  # sudo mkdir -p /etc/apt/keyrings                                                                                 # 创建公钥文件夹
  # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && # 添加 Docker 官方的 GPG 密钥
  #   echo \
  #     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  # $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null # 重新建立 apt 仓库
  # sudo apt-get update -y                                                               # 更新 apt 仓库
  # sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y  # 安装 docker 相关软件
  # service docker restart                                                               # 重启 docker 环境
  
  echo "安装/更新 docker 环境完成!"
}

# 规范化 Docker 容器名
function docker_container_name_conf() {
  if grep "container_name" ~/"$1".yml >/dev/null; then          # 如果已有默认容器
    sed -i "s/container_name.*/container_name: $1/g" ~/"$1".yml # 修改容器默认名称
  else
    sed -i "s/.*image.*/&\n&/g" ~/"$1".yml &&
      sed -i "0,/image.*/s/image.*/container_name: $1/" ~/"$1".yml # 添加容器名称
  fi
}

# 从 Docker compose 部署 docker 容器
function docker_install() {
  echo
  echo "---------- 从 Docker compose 部署 docker 容器 ----------"
  echo
  echo "检查 Docker 状态..."
  if docker -v; then
    echo "构建 Docker 容器"
    while true; do
      echo
      echo "已安装的 Docker 容器: "
      docker ps -a

      for i in "${!docker_list[@]}"; do
        printf "%2s. %-20s%-s\n" "$i" "${docker_list[$i]}" "${docker_list_info[$i]}" # 显示可安装容器列表
      done

      read -r -p "选择需要安装的 Docker 容器序号 (q:退出): " input
      case $input in
      0) # code-server: 在线 Web IDE
        read -rsp "设置密码: " password
        read -rsp "设置 sudo 密码: " sudo_password
        echo "PASSWORD=$password" >~/"${docker_list[$input]}".env # 将输入的密码，保存至新建的环境变量文件
        echo "SUDO_PASSWORD=$sudo_password" >>~/"${docker_list[$input]}".env
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml # 下载选择的 docker compose 文件
        docker_container_name_conf "${docker_list[$input]}"                                                               # 配置 docker compose 内的容器名
        docker compose -f ~/"${docker_list[$input]}".yml --env-file ~/"${docker_list[$input]}".env up -d                  # 从环境变量文件，构建容器
        ;;

      1) # nginx: Web 服务器
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml &&
          docker_container_name_conf "${docker_list[$input]}"
        docker compose -f ~/"${docker_list[$input]}".yml up -d
        ;;

      2) # pure-ftpd: FTP 服务器
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml
        docker_container_name_conf "${docker_list[$input]}"
        read -rp "设置 ftp 用户名: " ftp_username
        read -rsp "设置 ftp 密码: " ftp_password
        echo "FTP_USER_NAME=$ftp_username" >~/"${docker_list[$input]}".env
        echo "FTP_USER_PASS=$ftp_password" >>~/"${docker_list[$input]}".env
        docker compose -f ~/"${docker_list[$input]}".yml --env-file ~/"${docker_list[$input]}".env up -d
        ;;

      3) # web_object_detection: 在线 web 目标识别
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml &&
          docker_container_name_conf "${docker_list[$input]}"
        docker compose -f ~/"${docker_list[$input]}".yml up -d
        ;;

      4) # zfile: 在线云盘
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml &&
          # curl -o ~/application.properties https://c.jun6.net/ZFILE/application.properties &&
          docker_container_name_conf "${docker_list[$input]}"
        # while true; do
        #   read -rp "是否从远程服务器同步配置信息？(Y/n): " choose
        #   case $choose in
        #   [yY])
        #     read -rp "输入远程服务器地址（默认：39.105.22.218）: " rsync_ip
        #     read -rp "输入 ssh 用户名（默认：root）: " rsync_user
        #     read -rp "输入远程服务器中，配置文件所在文件夹的位置（以'/'结尾）（默认：/mnt/webdav/servers-conf/）: " rsync_dir
        #     read -rp "输入远程服务器中，配置文件的文件名（.tar.gz格式）（默认：zfile-backup.tar.gz）: " rsync_filename
        #     if [ -z "$rsync_ip" ]; then
        #       rsync_ip="39.105.22.218"
        #     fi
        #     if [ -z "$rsync_user" ]; then
        #       rsync_user="root"
        #     fi
        #     if [ -z "$rsync_dir" ]; then
        #       rsync_dir="/mnt/webdav/servers-conf/zfile/"
        #     fi
        #     if [ -z "$rsync_filename" ]; then
        #       rsync_filename="zfile-backup.tar.gz"
        #     fi
        #     # 压缩包内目录结构
        #     # .
        #     # ├── application.properties
        #     # └── zfile
        #     #     ├── db
        #     #     ├── file
        #     #     └── logs
        #     rsync -av "$rsync_user"@"$rsync_ip":"${rsync_dir}""${rsync_filename}" ~/ # 从远程服务器同步配置文件
        #     tar -xzvf ~/"${rsync_filename}" -C ~/                                    # 解压配置文件到指定目录（与 docker compose 文件中的配置对应）
        #     break
        #     ;;

        #   [nN]) break ;;
        #   *) echo "错误选项：$REPLY" ;;
        #   esac
        # done
        docker compose -f ~/"${docker_list[$input]}".yml up -d
        ;;

      5) # subconverter: 订阅转换后端
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml &&
          docker_container_name_conf "${docker_list[$input]}"
        docker compose -f ~/"${docker_list[$input]}".yml up -d
        ;;

      6) # sub-web: 订阅转换前端
        git clone https://github.com/CareyWang/sub-web ~/sub-web
        read -rp "设置订阅转换后端地址（默认：api.tsanfer.com:25500）：" sub_web_backend
        if [ -z "$sub_web_backend" ]; then
          sub_web_backend="api.tsanfer.com:25500"
        fi
        sed -i 's/^VUE_APP_SUBCONVERTER_DEFAULT_BACKEND.*/VUE_APP_SUBCONVERTER_DEFAULT_BACKEND = "/g' ~/sub-web/.env
        sed -i "s/^VUE_APP_SUBCONVERTER_DEFAULT_BACKEND.*/&http:\/\/$sub_web_backend/g" ~/sub-web/.env # 替换旧有的后端地址
        sed -i 's/^VUE_APP_SUBCONVERTER_DEFAULT_BACKEND.*/&"/g' ~/sub-web/.env
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml &&
          docker_container_name_conf "${docker_list[$input]}"
        docker compose -f ~/"${docker_list[$input]}".yml up -d
        ;;

      7) # mdserver-web: 一款简单Linux面板服务
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml &&
          docker_container_name_conf "${docker_list[$input]}"
        docker compose -f ~/"${docker_list[$input]}".yml up -d
        ;;

      8) # qinglong: 定时任务管理面板
        wget https://$github_raw/whyour/qinglong/master/docker/docker-compose.yml -O ~/"${docker_list[$input]}".yml &&
          docker_container_name_conf "${docker_list[$input]}"
        docker compose -f ~/"${docker_list[$input]}".yml up -d
        ;;

      9) # webdav-client: Webdav 客户端，同步映射到宿主文件系统
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml &&
          docker_container_name_conf "${docker_list[$input]}"

        read -rp "输入 webdav 服务器地址(url)（默认：https://dav.jianguoyun.com/dav/我的坚果云）: " webdav_url
        read -rp "输入 webdav 用户名（默认：a1124851454@gmail.com）: " webdav_user
        read -rsp "输入 webdav 密码: " webdav_pass
        read -rp "输入 webdav 本地目录（默认：/mnt/webdav）: " webdav_local_path
        if [ -z "$webdav_url" ]; then
          webdav_url="https://dav.jianguoyun.com/dav/我的坚果云"
        fi
        if [ -z "$webdav_user" ]; then
          webdav_user="a1124851454@gmail.com"
        fi
        if [ -z "$webdav_local_path" ]; then
          webdav_local_path="/mnt/webdav"
        fi

        echo "WEBDRIVE_URL=$webdav_url" >~/"${docker_list[$input]}".env
        echo "WEBDRIVE_USERNAME=$webdav_user" >>~/"${docker_list[$input]}".env
        echo "WEBDRIVE_PASSWORD=$webdav_pass" >>~/"${docker_list[$input]}".env
        echo "WEBDRIVE_LOCAL_PATH=$webdav_local_path" >>~/"${docker_list[$input]}".env
        docker compose -f ~/"${docker_list[$input]}".yml --env-file ~/"${docker_list[$input]}".env up -d
        ;;

      10) # watchtower: 自动化更新 Docker 容器
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml &&
          docker_container_name_conf "${docker_list[$input]}"
        read -rp "设置 Docker 镜像检查更新频率，单位：秒（默认：30）：" update_interval
        if [ -z "$update_interval" ]; then
          update_interval="30"
        fi
        echo "INTERVAL=$update_interval" >~/"${docker_list[$input]}".env
        docker compose -f ~/"${docker_list[$input]}".yml --env-file ~/"${docker_list[$input]}".env up -d
        ;;

      11) # jsxm: Web xm 音乐播放器
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -O ~/"${docker_list[$input]}".yml &&
          docker_container_name_conf "${docker_list[$input]}"
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
    echo
    echo "已下载的 Docker 镜像: "
    docker images -a # 显示当前所有 docker 镜像
    echo
    echo "已安装的 Docker 容器: "
    docker ps -a # 显示当前所有 docker 容器
  else
    echo "Docker 未安装!"
  fi
}

# 更新 docker 镜像和容器
function docker_update() {
  echo
  echo "---------- 更新 docker 镜像和容器 ----------"
  echo
  echo "检查 Docker 状态..."
  if docker -v; then
    echo
    echo "已安装的 Docker 容器: "
    docker ps -a
    while true; do

      for i in "${!docker_list[@]}"; do
        printf "%2s. %-20s%-s\n" "$i" "${docker_list[$i]}" "${docker_list_info[$i]}" # 显示容器列表
      done

      read -r -p "选择需要更新的 Docker 容器序号 (q:退出): " input
      case $input in
      [4]) # zfile: 在线云盘
        docker run --rm \
          -v /var/run/docker.sock:/var/run/docker.sock \
          containrrr/watchtower \
          --cleanup \
          --run-once \
          zfile
        ;;
      [qQ]) break ;;
      *) echo "暂无 ${docker_list[$input]} 的更新脚本" ;;
      esac
    done
    echo
    echo "已下载的 Docker 镜像: "
    docker images -a # 显示当前所有 docker 镜像
    echo
    echo "已安装的 Docker 容器: "
    docker ps -a # 显示当前所有 docker 容器
  else
    echo "Docker 未安装!"
  fi
}

# 删除 docker 镜像和容器
function docker_remove() {
  echo
  echo "---------- 删除 docker 镜像和容器 ----------"
  echo
  echo "检查 Docker 状态..."
  if docker -v; then
    echo
    echo "已安装的 Docker 容器: "
    docker ps -a
    while true; do

      for i in "${!docker_list[@]}"; do
        printf "%2s. %-20s%-s\n" "$i" "${docker_list[$i]}" "${docker_list_info[$i]}" # 显示容器列表
      done

      read -r -p "选择需要删除的 Docker 容器序号 (q:退出): " input
      case $input in
      # *) echo "错误选项：$REPLY" ;;
      [qQ]) break ;;
      *) docker stop "${docker_list[$input]}" ;; # 停止指定容器
      esac
    done
    docker system prune -a -f # 清除 docker 中未使用的数据（包括停止的容器以及其镜像）
    echo
    echo "已下载的 Docker 镜像: "
    docker images -a # 显示当前所有 docker 镜像
    echo
    echo "已安装的 Docker 容器: "
    docker ps -a # 显示当前所有 docker 容器
  else
    echo "Docker 未安装!"
  fi
}

# 清理 APT 空间
function apt_clean() {
  echo
  echo "---------- 清理 APT 空间 ----------"
  echo
  while true; do
    read -rp "是否清理 APT 空间？(Y/n): " input
    case $input in
    [yY])
      sudo apt clean -y &&     # 删除存储在本地的软件安装包
        sudo apt purge -y &&   # 删除软件配置文件
        sudo apt autoremove -y # 删除不再需要的依赖软件包
      break
      ;;

    [nN]) break ;;
    *) echo "错误选项：$REPLY" ;;
    esac
  done
}

# 重启系统
function sys_reboot() {
  echo
  echo "---------- 重启系统 ----------"
  echo
  while true; do
    read -rp "是否重启系统？(Y/n): " input
    case $input in
    [yY])
      reboot # 重启系统
      exit
      ;;

    [nN]) break ;;
    *) echo "错误选项：$REPLY" ;;
    esac
  done
}

# ----- 程序开始位置 -----
github_proxy_set

if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "debian" ] || [[ "$ID_LIKE" =~ "debian" ]]; then
        echo "操作系统基于 Debian"

        while true; do
          echo
          echo "选择要运行的脚本: "
          echo "----------------------------------------------------------------------"
          for i in "${!script_list[@]}"; do
            printf "|%2s.|%-20s|%-s|\n" "$((i + 1))" "${script_list[$i]}" "${script_list_info[$i]}" # 显示脚本列表
            echo "----------------------------------------------------------------------"
          done
          echo "i. 初始化配置脚本"
          echo "----------------------------------------------------------------------"
          read -r -p "选择要进行的操作 (q:退出): " input
          case $input in
          [iI])
            app_update_init &&
            swap_set &&
            vps_reviews &&
            term_config &&
            docker_init &&
            app_install &&
            docker_install &&
            apt_clean &&
            sys_reboot
            ;;
          [qQ]) break ;;
          *)
            if [[ "$input" =~ ^[0-9]+$ ]]; then
              input=$((input - 1)) # 将用户输入的序号减1，以匹配数组索引
              if ((input >= 0 && input < ${#script_list[@]})); then
                ${script_list[$input]}
              else
                echo "错误选项：$((input + 1))"
              fi
            else
              echo "错误选项：$input"
            fi
            ;;
          esac
        done
        echo "Done!!!"
        zsh # 进入新终端

    else
        echo "操作系统不是基于 Debian"
    fi
else
    echo "无法识别操作系统 /etc/os-release 文件未找到"
fi

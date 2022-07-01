#!/bin/bash
# 文件位置：$HOME/Setup.sh

github_repo="github.daocloudcom"
github_download="github.com"
github_raw="raw.githubusercontent.com"

function github_proxy_set() {
  while true; do
    read -r -p "是否启用 Github 国内加速? [Y/n] " input
    case $input in
    [yY])
      # git config --global url."https://hub.fastgit.xyz/".insteadOf https://github.com/
      github_repo="mirror.ghproxy.com/github.com"
      github_download="mirror.ghproxy.com/github.com"
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
      github_download="github.com"
      github_raw="raw.githubusercontent.com"
      break
      ;;

    *)
      echo "Invalid input..."
      ;;
    esac
  done
}

function app_install() {
  echo
  echo "---------- 应用安装 ----------"
  echo
  sudo apt update -y &&
    sudo apt upgrade -y &&
    sudo apt install zsh git vim unzip bc curl wget -y &&
    if ! btm --version; then
      wget https://$github_download/ClementTsang/bottom/releases/download/0.6.8/bottom_0.6.8_amd64.deb -NP ~ &&
        sudo dpkg -i ~/bottom_0.6.8_amd64.deb
    else
      echo "已安装 bottom"
    fi

  if ! neofetch --version; then
    if ! sudo apt install neofetch -y; then
      git clone https://$github_repo/dylanaraps/neofetch &&
        make -C ~/neofetch install
    fi
  else
    echo "已安装 neofetch"
  fi

  neofetch
  read -r -p "按回车键继续"
}

function term_config() {
  echo
  echo "---------- 配置终端 ----------"
  echo
  chsh -s "$(which zsh)" &&
    RUNZSH=no sh -c "$(curl -fsSL https://$github_raw/ohmyzsh/ohmyzsh/master/tools/install.sh)" &&
    git clone https://$github_repo/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions &&
    git clone https://$github_repo/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting &&
    sed -i 's/^plugins=(/plugins=(\nzsh-autosuggestions\nzsh-syntax-highlighting\n/g' ~/.zshrc &&
    sudo wget https://${github_download}/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh &&
    sudo chmod +x /usr/local/bin/oh-my-posh &&
    mkdir ~/.poshthemes &&
    wget https://${github_download}/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip &&
    unzip ~/.poshthemes/themes.zip -d ~/.poshthemes &&
    chmod u+rw ~/.poshthemes/*.omp.* &&
    rm ~/.poshthemes/themes.zip &&
    sed -i '$a\eval "$(oh-my-posh --init --shell zsh --config ~/.poshthemes/craver.omp.json)"' ~/.zshrc
  wget https://${github_raw}/Tsanfer/Setup_server/main/.vimrc -NP ~
}

function swap_set() {
  free -h

  while true; do
    read -r -p "配置 swap 功能 (Y:覆盖/n:关闭/q:跳过): " input
    case $input in
    [yY])
      swapoff -a
      awk '/swap/ {print $1}' /etc/fstab | xargs rm
      sed -i '/swap/d' /etc/fstab
      read -rp "设置 swap 大小 (单位 MB): " swap_size
      ((swap_size *= 1024))
      dd if=/dev/zero of=/var/swap bs=1024 count="$swap_size"
      mkswap /var/swap
      chmod 600 /var/swap
      read -rp "设置内存剩余小于百分之多少时，才启用 swap (单位 %): " swap_enable_threshold
      sed -i "s/^vm.swappiness.*/vm.swappiness=$swap_enable_threshold/g" /etc/sysctl.conf
      sysctl -p
      swapon /var/swap
      echo "/var/swap swap swap defaults 0 0" >>/etc/fstab
      break
      ;;

    [nN])
      swapoff -a
      awk '/swap/ {print $1}' /etc/fstab | xargs rm
      sed -i '/swap/d' /etc/fstab
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

function docker_install() {
  echo
  echo "---------- 安装/更新 Docker ----------"
  echo
  release_ver=$(awk '/Ubuntu/ {print $2}' /etc/issue | awk -F. '{printf "%s.%s\n",$1,$2}')
  if echo "$(echo "$release_ver" | bc) >= 18.04" | bc; then
    echo "安装/更新 Docker 环境..."
    if docker -v; then
      docker rm -f "$(docker ps -aq)"
    fi
    # sudo apt-get remove docker docker-engine docker.io containerd runc && \
    sudo apt-get install \
      ca-certificates \
      curl \
      gnupg \
      lsb-release -y &&
      sudo mkdir -p /etc/apt/keyrings &&
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null &&
      sudo apt-get update -y &&
      sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    echo "安装/更新 docker 环境完成!"
  else
    echo "The Ubuntu version is lower than 18.04, can't install docker."
  fi
}

function docker_deploy() {
  echo
  echo "---------- 运行 Docker-compose ----------"
  echo
  echo "检查 Docker 状态..."
  if docker -v; then
    wget https://$github_raw/Tsanfer/Setup_server/main/docker-compose.yml -NP ~ &&
      docker compose up -d &&
      echo "安装 Docker 容器"
    docker_list=("code-server" "nginx" "pure-ftpd")
    while true; do
      for i in "${!docker_list[@]}"; do
        echo "$i. ${docker_list[$i]}"
      done
      read -rp "选择需要安装的 Docker 容器（q:退出）: " input
      case $input in
      [0])
        read -rps "设置密码: " password
        echo
        read -rps "设置 sudo 密码: " sudo_password
        echo "PASSWORD=$password" >~/"${docker_list[$input]}".env
        echo "SUDO_PASSWORD=$sudo_password" >>~/"${docker_list[$input]}".env
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -NP ~ &&
          docker compose -f ~/"${docker_list[$input]}".yml --env-file ~/"${docker_list[$input]}".env up -d
        ;;
      [1])
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -NP ~ &&
          docker compose -f ~/"${docker_list[$input]}" up -d
        ;;
      [2])
        read -rp "设置 ftp 用户名: " ftp_username
        echo
        read -rps "设置 ftp 密码: " ftp_password
        echo "FTP_USER_NAME=$ftp_username" >~/"${docker_list[$input]}".env
        echo "FTP_USER_PASS=$ftp_password" >>~/"${docker_list[$input]}".env
        wget https://$github_raw/Tsanfer/Setup_server/main/"${docker_list[$input]}".yml -NP ~ &&
          docker compose -f ~/"${docker_list[$input]}".yml --env-file ~/"${docker_list[$input]}"e.env up -d
        ;;
      [qQ])
        break
        ;;
      *)
        echo "错误选项：$REPLY"
        ;;
      esac
    done
    docker ps
  else
    echo "Docker 未安装!"
  fi
}

function apt_clean() {
  while true; do
    read -rp "是否清理 APT 空间？(Y/n): " input
    case $input in
    [yY])
      sudo apt clean -y &&
        sudo apt purge -y &&
        sudo apt autoremove -y
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
  while true; do
    read -rp "是否重启系统？(Y/n): " input
    case $input in
    [yY])
      reboot
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

if grep "Ubuntu" /etc/issue; then
  app_install &&
    term_config &&
    swap_set &&
    docker_install &&
    docker_deploy &&
    apt_clean
  echo "Done!!!"
  zsh
else
  echo "linux 系统不是 Ubuntu"
fi

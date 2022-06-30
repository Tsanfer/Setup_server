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
      # wget https://${github_download}/dotnetcore/FastGithub/releases/latest/download/fastgithub_linux-x64.zip -P ~ &&
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
    wget https://${github_download}/ClementTsang/bottom/releases/download/0.6.8/bottom_0.6.8_amd64.deb -P ~ &&
    sudo dpkg -i ~/bottom_0.6.8_amd64.deb &&
    if ! sudo apt install neofetch -y; then
      git clone https://${github_repo}/dylanaraps/neofetch &&
        make -C ~/neofetch install
    fi
  neofetch
  read -r -p "按回车键继续"
}

function term_config() {
  echo
  echo "---------- 配置终端 ----------"
  echo
  chsh -s $(which zsh) &&
    RUNZSH=no sh -c "$(curl -fsSL https://${github_raw}/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://${github_repo}/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions &&
    git clone https://${github_repo}/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting &&
    sed -i 's/^plugins=(/plugins=(\nzsh-autosuggestions\nzsh-syntax-highlighting\n/g' ~/.zshrc &&
    sudo wget https://${github_download}/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh &&
    sudo chmod +x /usr/local/bin/oh-my-posh &&
    mkdir ~/.poshthemes &&
    wget https://${github_download}/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip &&
    unzip ~/.poshthemes/themes.zip -d ~/.poshthemes &&
    chmod u+rw ~/.poshthemes/*.omp.* &&
    rm ~/.poshthemes/themes.zip &&
    sed -i '$a\eval "$(oh-my-posh --init --shell zsh --config ~/.poshthemes/craver.omp.json)"' ~/.zshrc
  wget https://${github_raw}/Tsanfer/Setup_server/main/.vimrc -P ~
}

function docker_install() {
  echo
  echo "---------- 安装 Docker ----------"
  echo
  echo "检查 Docker 状态..."
  docker -v
  if [ $? -eq 0 ]; then
    release_ver=$(awk '/Ubuntu/ {print $2}' /etc/issue | awk -F. '{printf "%s.%s\n",$1,$2}')
    echo "$(echo $release_ver | bc) >= 18.04" | bc
    if [ $? -eq 0 ]; then
      echo "安装 Docker 环境..."
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
      echo "安装docker环境...安装完成!"
      docker_install && docker_deploy
    else
      echo "The Ubuntu version is lower than 18.04, can't install docker."
    fi
  else
    echo "检查到 Docker 已安装!"
  fi

}

function swap_set() {
  free -h

  while true; do
    read -r -p "关闭还是启用 swap 功能? (Y:启用/n:关闭/q:退出): " input
    case $input in
    [yY])
      read -r -p "设置 swap 大小 (单位 MB): " swap_size
      let swap_size*=1024
      dd if=/dev/zero of=/var/swap bs=1024 count=$swap_size
      mkswap /var/swap
      read -r -p "设置内存剩余小于百分之多少时，才启用 swap (单位 %): " swap_enable_threshold
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
      echo "Invalid input..."
      ;;
    esac
  done
}

function docker_deploy() {
  echo
  echo "---------- 运行 Docker-compose ----------"
  echo
  echo "检查 Docker 状态..."
  docker -v
  if [ $? -eq 0 ]; then
    wget https://${github_raw}/Tsanfer/Setup_server/main/docker-compose.yml -P ~ &&
      docker compose up -d &&
      PS3="选择需要安装的 Docker 容器: "
    docker_list=("code-server" "Quit")
    select compose in "${docker_list[@]}"; do
      case $compose in
      "code-server")
        read -s -p "设置密码: " password
        read -s -p "设置 sudo 密码: " sudo_password
        echo "PASSWORD=$password" >>~/$compose.env
        echo "SUDO_PASSWORD=$sudo_password" >>~/$compose.env
        wget https://${github_raw}/Tsanfer/Setup_server/main/$compose.yml -P ~ &&
          docker compose -f ~/$compose.yml --env-file ~/$compose.env up -d &&
          break
        ;;
      "Quit")
        echo "退出"
        break
        ;;
      *) echo "错误选项：$REPLY" ;;
      esac
    done
    docker ps
  else
    echo "Docker 未安装!"
  fi
}

function phpstudy_install() {
  while true; do
    read -r -p "是否安装小皮面板？[Y/n]: " input
    case $input in
    [yY])
      wget -O install.sh https://download.xp.cn/install.sh && sudo bash install.sh
      break
      ;;

    [nN])
      break
      ;;

    *)
      echo "Invalid input..."
      ;;
    esac
  done
}

github_proxy_set

grep "Ubuntu" /etc/issue
if [ $? -eq 0 ]; then
  app_install &&
    term_config &&
    swap_set
  phpstudy_install || docker_install
  docker_deploy
  echo "Done!!!"
  zsh
else
  echo "The linux version is not Ubuntu"
fi

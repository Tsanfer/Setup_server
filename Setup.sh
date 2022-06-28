#!/bin/bash
# 更新日期：2022/06/23
# 文件位置：$HOME

github_repo="github.com"
github_download="github.com"
github_raw="raw.githubusercontent.com"

function github_proxy_set() {
  while true; do
    read -r -p "是否启用 Github 国内加速? [Y/n] " input
    case $input in
    [yY][eE][sS] | [yY])
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

    [nN][oO] | [nN])
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

function apt_update() {
  echo
  echo "----------  APT 更新 ----------"
  echo
  sudo apt update -y &&
    sudo apt upgrade -y &&
    sudo apt install zsh git vim unzip -y &&
    if ! sudo apt install neofetch -y; then
      git clone https://${github_repo}/dylanaraps/neofetch &&
        make -C ~/neofetch install
    fi
  neofetch
  read -p "按回车键继续"
}

function term_config() {
  echo
  echo "---------- 配置终端 ----------"
  echo
  chsh -s $(which zsh) &&
    if ! RUNZSH=no sh -c "$(curl -fsSL https://${github_raw}/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
      while true; do
        read -r -p "是否重新安装 oh-my-zsh? [Y/n] " input
        case $input in
        [yY][eE][sS] | [yY])
          rm -rf ~/.oh-my-zsh ~/.poshthemes
          RUNZSH=no sh -c "$(curl -fsSL https://${github_raw}/ohmyzsh/ohmyzsh/master/tools/install.sh)"
          break
          ;;

        [nN][oO] | [nN])
          break
          ;;

        *)
          echo "Invalid input..."
          ;;
        esac
      done
    fi
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
    sed -i '$a\eval "$(oh-my-posh --init --shell zsh --config ~/.poshthemes/craver.omp.json)"' ~/.zshrc &&
    wget https://${github_raw}/Tsanfer/Setup_server/main/.vimrc -P ~
}

function docker_install() {
  echo
  echo "---------- 安装 Docker ----------"
  echo
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
}

function docker_deploy() {
  echo
  echo "---------- 运行 Docker-compose ----------"
  echo
  wget https://${github_raw}/Tsanfer/Setup_server/main/docker-compose.yml -P ~ &&
    docker compose up -d &&
    PS3="选择需要安装的 Docker 容器: "
  docker_list=("code-server" "halo-blog" "Quit")
  select compose in "${docker_list[@]}"; do
    case $compose in
    "code-server")
      read -p "设置密码: " password
      read -p "设置 sudo 密码: " sudo_password
      echo "PASSWORD=$password" >>~/$compose.env
      echo "SUDO_PASSWORD=$sudo_password" >>~/$compose.env
      wget https://${github_raw}/Tsanfer/Setup_server/main/$compose.yml -P ~ &&
        docker compose -f ~/$compose.yml --env-file ~/$compose.env up -d &&
        break
      ;;
    "halo-blog")
      wget https://${github_raw}/Tsanfer/Setup_server/main/$compose.yml -P ~ &&
        docker compose -f ~/$compose.yml up -d &&
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
}

github_proxy_set

release_ver=$(awk '{print $2}' /etc/issue)

if grep "Ubuntu" /etc/issue; then
  apt_update && term_config
  if (($(echo "$($release_ver | awk -F. '{printf "%s.%s\n",$1,$2}' | bc) >= 18.04" | bc))); then
    docker_install && docker_deploy
  else
    echo "The Ubuntu version is lower than 18.04, can't install docker."
  fi
  echo "Done!!!"
  zsh
else
  echo "The linux version is not Ubuntu"
  return 1
fi

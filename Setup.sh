#!/bin/bash 
# 更新日期：2022/06/23
# 文件位置：$HOME

Install_docker(){
  echo
  echo "---------- 安装 Docker ----------"
  echo
  # sudo apt-get remove docker docker-engine docker.io containerd runc && \ 
  sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y && \
  sudo mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  sudo apt-get update -y && \
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

# github_download="github.com"
# github_raw="raw.githubusercontent.com"

while true
do
  read -r -p "是否启用国内加速? [Y/n] " input
  case $input in
      [yY][eE][sS]|[yY])
      # git config --global url."https://hub.fastgit.xyz/".insteadOf https://github.com/
      # github_raw="raw.fastgit.org"
      # github_download="download.fastgit.org"
      Install_docker && \
      wget -O ~/FastGithub.yaml https://hub.fastgit.xyz/dotnetcore/FastGithub/raw/master/docker-compose.yaml && \
      docker compose -f ~/FastGithub.yaml up -d
      break
      ;;

      [nN][oO]|[nN])
      # git config --global --remove-section url."https://hub.fastgit.xyz/"
      # github_raw="raw.githubusercontent.com"
      # github_download="github.com"
      break	       	
      ;;

      *)
      echo "Invalid input..."
      ;;
  esac
done

if lsb_release -a | grep Ubuntu
then
  echo
  echo "---------- 1. APT 更新 ----------"
  echo
  sudo apt update -y && \
  sudo apt upgrade -y && \
  sudo apt install zsh git vim unzip -y && \
  if ! sudo apt install neofetch -y
  then
    git clone https://github.com/dylanaraps/neofetch && \
    make -C ~/neofetch install
  fi
  neofetch && \
  read -p "按回车键继续"
  echo
  echo "---------- 2. 配置终端 ----------"
  echo
  chsh -s $(which zsh) && \
  RUNZSH=no sh -c "$(curl -fsSL https://${github_raw}/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
  sed -i 's/^plugins=(/plugins=(\nzsh-autosuggestions\nzsh-syntax-highlighting\n/g' ~/.zshrc && \
  sudo wget https://${github_download}/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh && \
  sudo chmod +x /usr/local/bin/oh-my-posh && \
  mkdir ~/.poshthemes && \
  wget https://${github_download}/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip && \
  unzip ~/.poshthemes/themes.zip -d ~/.poshthemes && \
  chmod u+rw ~/.poshthemes/*.json && \
  rm ~/.poshthemes/themes.zip && \
  sed -i '$a\eval "$(oh-my-posh --init --shell zsh --config ~/.poshthemes/craver.omp.json)"' ~/.zshrc && \
  zsh && \
  source ~/.zshrc && \
  echo
  echo "---------- 4. 运行 Docker-compose ----------"
  echo
  docker compose up -d && \
  
  PS3="选择需要安装的 Docker 容器: "
  docker_list=("code-server" "halo-blog" "Quit")
  select compose in "${docker_list[@]}"
  do
    case $compose in
      "code-server")
        read -p "设置密码: " password
        read -p "设置 sudo 密码: " sudo_password
        echo "PASSWORD=${password}" >> ~/$compose.env
        echo "SUDO_PASSWORD=${sudo_password}" >> ~/$compose.env
        docker compose -f https://github.com/Tsanfer/Setup_server/raw/main/$compose.yml --env-file ~/$compose.env up -d
        ;;
      "halo-blog")
        docker compose -f https://github.com/Tsanfer/Setup_server/raw/main/$compose.yml --env-file ~/$compose.env up -d
        break
        ;;
      "Quit")
        echo "退出"
        break
        ;;
      *) echo "错误选项：$REPLY";;
    esac
  done

  docker ps && \
  echo "Done!!!"
else
  echo "The linux version is not Ubuntu"
  return 1
fi

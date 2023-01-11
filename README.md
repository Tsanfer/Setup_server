# 个人 Ubuntu 服务器自动初始化脚本

> Linux 发行版：Ubuntu

> 安装时，可选择国内 Github 镜像加速

- APT 软件更新安装
  - [`bottom`](https://github.com/ClementTsang/bottom)：监控系统资源使用情况（使用命令: `btm`）
  - [`neofetch`](https://github.com/dylanaraps/neofetch)：查看系统信息（使用命令: `neofetch`）
- 配置终端
  - [`Oh-my-zsh`](https://github.com/ohmyzsh/ohmyzsh) 及插件安装
  - [`Oh-my-posh`](https://github.com/JanDeDobbeleer/oh-my-posh) 安装
- 配置 swap 内存
- Docker 安装/更新
- 从 Docker compose 安装/删除 docker 容器
  
  |Docker 容器|功能|端口|
  |--|--|--|
  |[code-server](https://github.com/coder/code-server)|在线 Web IDE|`8443`|
  |[nginx](https://hub.docker.com/_/nginx)|Web 服务器|`80`|
  |[pure-ftpd](https://hub.docker.com/r/stilliard/pure-ftpd)|FTP 服务器|主动端口：`21`|
  |[web_object_detection](https://github.com/Tsanfer/web_object_detection)|在线 web 目标识别|前端端口：`8000`<br/>后端端口：`4000`|
  |[zfile](https://github.com/zfile-dev/zfile)|在线网盘|`8080`|
  |[subconverter](https://github.com/tindy2013/subconverter)|订阅转换后端|`25500`|
  |[subweb](https://github.com/CareyWang/sub-web)|订阅转换前端|`58080`|
  |[mdserver-web](https://github.com/midoks/mdserver-web)|一款简单 Linux 面板服务|`7200` `80` `443` `888`|
  |[青龙面板](https://github.com/whyour/qinglong)|定时任务管理面板|`5700`|

- 清理 APT 空间，重启系统

## 一键脚本

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Tsanfer/Setup_server/main/Setup.sh)"
```

或

```bash
bash -c "$(wget https://raw.githubusercontent.com/Tsanfer/Setup_server/main/Setup.sh -O -)"
```

### 国内使用

```bash
bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/Tsanfer/Setup_server/main/Setup.sh)"
```

或

```bash
bash -c "$(wget https://ghproxy.com/https://raw.githubusercontent.com/Tsanfer/Setup_server/main/Setup.sh -O -)"
```

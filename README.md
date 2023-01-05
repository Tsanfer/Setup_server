# 个人 Ubuntu 服务器自动初始化脚本

> Linux 发行版：Ubuntu

> 安装时，可选择国内 Github 镜像加速

- APT 软件更新安装
  - `bottom`：监控系统资源使用情况
  - `neofetch`：查看系统信息
- 配置终端
  - `Oh-my-zsh` 及插件安装
  - `Oh-my-posh` 安装
- 配置 swap 内存
- Docker 安装/更新
- 从 Docker compose 部署 docker 容器
  - `portainer_agent`: Docker 多容器管理客户端
  - `code-server`: 在线 Web IDE
  - `nginx`: Web 服务器
  - `pure-ftpd`: FTP 服务器
  - `web_object_detection`: 在线 web 目标识别
  - `zfile`: 在线网盘
  - `subconverter`: 订阅转换后端
  - `subweb`: 订阅转换前端
  - `mdserver-web`: 一款简单Linux面板服务

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

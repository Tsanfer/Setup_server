# 个人 Ubuntu 服务器自动初始化脚本

> Linux 发行版：Ubuntu

> 安装时，可选择国内 Github 镜像加速

- APT 软件更新、默认软件安装
  | 部分默认软件                                             | 功能           | 命令       |
  | -------------------------------------------------------- | -------------- | ---------- |
  | [rsync](https://github.com/coder/code-server)            | 文件同步       | `rsync`    |
  | [bottom](https://hub.docker.com/_/nginx)                 | 图形化系统监控 | `btm`      |
  | [neofetch](https://hub.docker.com/r/stilliard/pure-ftpd) | 系统信息工具   | `neofetch` |

- 配置 swap 内存
- 配置终端
  - [Oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) 及插件安装（加强 zsh 的功能）
  - [Oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh) 安装（终端提示符美化）
- 自选软件安装/卸载
  | 自选软件                                               | 功能                              | 命令 |
  | ------------------------------------------------------ | --------------------------------- | ---- |
  | [mdserver-web](https://github.com/midoks/mdserver-web) | 一款简单Linux面板服务（宝塔翻版） | `mw` |
  | [aaPanel](https://www.aapanel.com/new/index.html)      | 宝塔国外版                        | `bt` |

- 安装和更新 Docker
- 安装/删除 docker 容器
  | Docker 容器                                                             | 功能                                  | 端口                                  |
  | ----------------------------------------------------------------------- | ------------------------------------- | ------------------------------------- |
  | [code-server](https://github.com/coder/code-server)                     | 在线 Web IDE                          | `8443`                                |
  | [nginx](https://hub.docker.com/_/nginx)                                 | Web 服务器                            | `80`                                  |
  | [pure-ftpd](https://hub.docker.com/r/stilliard/pure-ftpd)               | FTP 服务器                            | 主动端口：`21`                        |
  | [web_object_detection](https://github.com/Tsanfer/web_object_detection) | 在线 web 目标识别                     | 前端端口：`8000`<br/>后端端口：`4000` |
  | [zfile](https://github.com/zfile-dev/zfile)                             | 在线网盘（可从服务器同步配置信息）    | `8080`                                |
  | [subconverter](https://github.com/tindy2013/subconverter)               | 订阅转换后端                          | `25500`                               |
  | [subweb](https://github.com/CareyWang/sub-web)                          | 订阅转换前端                          | `58080`                               |
  | [mdserver-web](https://github.com/midoks/mdserver-web)                  | 一款简单 Linux 面板服务               | `7200` `80` `443` `888`               |
  | [青龙面板](https://github.com/whyour/qinglong)                          | 定时任务管理面板                      | `5700`                                |
  | [webdav-client](https://github.com/efrecon/docker-webdav-client)        | Webdav 客户端，同步映射到宿主文件系统 |                                       |
  | [watchtower](https://github.com/containrrr/watchtower)                  | 自动化更新 Docker 镜像和容器          |                                       |
  | [jsxm](https://github.com/a1k0n/jsxm)                                   | Web 在线 xm 音乐播放器器              | `8081`                                |

- 清理 APT 空间

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

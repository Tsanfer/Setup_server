#!/bin/bash
# file: $HOME/swap_set.sh

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

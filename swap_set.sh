#!/bin/bash
# file: $HOME/swap_set.sh

free -h

while true; do
  read -r -p "配置 swap 功能 (Y:覆盖/n:关闭/q:跳过): " input
  case $input in
  [yY])
    if ! swapoff -a; then
      echo "释放 swap 内存失败，请尝试预留更多物理内存后重试"
    fi
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

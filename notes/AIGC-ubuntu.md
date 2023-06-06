## AIGC ubuntu 环境搭建

### 安装 malloc

[参考](https://installati.one/install-libtcmalloc-minimal4-ubuntu-22-04/)

```sh
sudo apt update
sudo apt -y install libtcmalloc-minimal4
sudo apt install --no-install-recommends google-perftools
# 查看安装结果
dpkg -l |grep malloc
```

### 安装 GPU 驱动

```sh
# 查看适用驱动版本(标记了 recommended)
ubuntu-drivers devices
# 使用一下命令或在 GUI 软件更新中进行安装
sudo apt install nvidia-driver-525
# 重启
sudo reboot
# 查看 GPU 信息
nvidia-smi
```

### 安装 cuda

https://developer.nvidia.com/cuda-downloads

### 间隔 2s 查看 GPU 运行情况

```
watch -n 2 nvidia-smi
```

### 查看传感器温度

```sh
# 安装
sudo apt install lm-sensors
# 间隔 1s 查看
watch -n 1 sensors
# 获取 GPU ID 信息
nvidia-smi -L
```

### 智能安装依赖

```
sudo apt-get install aptitude
sudo aptitude install package name
```
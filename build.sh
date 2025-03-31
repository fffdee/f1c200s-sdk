#!/bin/bash


# rkdeveloptool db rkxx_loader_vx.xx.bin
# rkdeveloptool wl 0x40 idbLoader.img
# rkdeveloptool wl 0x4000 uboot.itb
# rkdeveloptool wl 0x8000 boot.itb
# rkdeveloptool wl 0x40000 ubuntu_ext4.img

# set -e

PROJERCT_PATH=$(pwd)
# 初始化配置文件路径
INIT_CONFIG_FILE="$PROJERCT_PATH/init_config.defconfig"
# 默认值
DEFAULT_INIT_STATUS=n
# TOOLCHAIN_STATUS=n
# KERNEL_STATUS=n
UBOOT_NAME="u-boot"
KERNEL_NAME="linux-5.7.1"
ROOTFS_NAME="debian"
KERNEL_PATH="$PROJERCT_PATH/../$KERNEL_NAME"
UBOOT_PATH="$PROJERCT_PATH/../$UBOOT_NAME"
ROOTFS_PATH="$PROJERCT_PATH/../$ROOTFS_NAME"
ENV_PATH="/etc/profile"

TOOlCHAIN_PATH="/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi"

DTB_NAME="BanNano.dtb"

# 设置镜像文件名和大小
# 定义变量
IMG_FILE="BanNano.img"
IMG_SIZE=2G
PART1_SIZE=32M
PART1_OFFSET=1M
ZIMAGE_FILE="zImage"
DTB_FILE="BanNano.dtb"
BOOT_SCR_FILE="boot.scr"
ROOTFS_TAR="rootfs_debian.tar"

# 检查初始化状态
check_init_status() {
    local init_status
    if [ -f "$INIT_CONFIG_FILE" ]; then
        # 读取初始化状态
        init_status=$(grep "CONFIG_INIT_STATUS" "$INIT_CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')
    else
        # 如果配置文件不存在，初始化状态为默认值
        init_status=$DEFAULT_INIT_STATUS
    fi
    echo "$init_status"
}

check_kernel_status() {
    local kernel_stDownload atus
    if [ -f "$INIT_CONFIG_FILE" ]; then
        # 读取初始化状态
        kernel_status=$(grep "KERNEL_STATUS" "$INIT_CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')
    else
        # 如果配置文件不存在，初始化状态为默认值
        kernel_status=$DEFAULT_INIT_STATUS
    fi
    echo "$kernel_status"
}


# 检查工具链状态
check_toolchain_status() {
    local toolchain_status
    if [ -f "$INIT_CONFIG_FILE" ]; then
        # 读取工具链状态
        toolchain_status=$(grep "TOOLCHAIN_STATUS" "$INIT_CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')
    else
        # 如果配置文件不存在，工具链状态为默认值
        toolchain_status=$DEFAULT_INIT_STATUS
    fi
    echo "$toolchain_status"
}


# 检查工具链状态
check_rootfs_status() {
    local rootfs_status
    if [ -f "$INIT_CONFIG_FILE" ]; then
        # 读取工具链状态
        rootfs_status=$(grep "ROOTFS_STATUS" "$INIT_CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')
    else
        # 如果配置文件不存在，工具链状 
态为默认值
        rootfs_status=$DEFAULT_INIT_STATUS
    fi
    echo "$rootfs_status"
}

# 下载并解压工具链
download_and_extract_toolchain() {
    echo "下载工具链"

    wget -P ./download http://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/arm-linux-gnueabi/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi.tar.xz

    tar -vxJf ./download/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi.tar.xz

    sudo mv  gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi /opt/

    # 将工具链路径写入 /etc/profile
    
    if grep -q "$TOOlCHAIN_PATH" "$ENV_PATH"; then
        echo " '$TOOlCHAIN_PATH' 存在于文件 $ENV_PATH 中"
    else
        echo "'$TOOlCHAIN_PATH' 不存在于文件$ROOTFS_NAME $ENV_PATH 中"
        sudo sh -c 'echo "export PATH=\$PATH:/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi/bin" > '$ENV_PATH
    fi

    
  
    # 查看 /etc/profile 的内容
    cat /etc/profile

    # 刷新环境变量
    

    
    # 更新工具链状态
    update_toolchain_status
}

# 解压 tar 文件
extract_kernel() {

    cd $PROJERCT_PATH
    # wget -P ./download http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/v5.x/linux-6.3.tar.gz
    # https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.13.7.tar.xz
    wget -P ./download https://mirrors.aliyun.com/linux-kernel/v5.x/linux-5.7.1.tar.gz
    tar -zvxf ./download/linux-5.7.1.tar.gz -C  ../ 
    update_kernel_status    
}
        
# 解压 tar 文件
extract_uboot() {

    cd $PROJERCT_PATH/../
    git clone https://github.com/Lichee-Pi/u-boot.git -b nano-v2018.01
    
    update_init_status
   
}
ready_rootfs() {

    # 进入项目路径的上一级目录
    cd "$PROJERCT_PATH/../"

 # 设置目标目录
TARGET_DIR="./debian"

# 设置Debian版本和架构
DEBIAN_VERSION="bookworm"  # 替换为所需的Debian版本，如bullseye、buster等
ARCH="armel"               # 替换为所需的架构，如i386、arm64等

# 设置软件源
MIRROR="http://mirrors.tuna.tsinghua.edu.cn/debian/"

# 设置用户信息
USERNAME="bango"
PASSWORD="12345616"  # 注意：在实际使用中，建议使用更安全的密码设置方式

# 检查是否为root用户

# 安装debootstrap
echo "安装debootstrap..."
sudo apt update
sudo apt install -y debootstrap

# 创建目标目录
echo "创建目标目录..."
mkdir -p "$TARGET_DIR"

# 使用debootstrap创建基础系统
echo "使用debootstrap创建基础系统..."
sudo debootstrap --arch="$ARCH" "$DEBIAN_VERSION" "$TARGET_DIR" "$MIRROR"

# 检查debootstrap是否成功
if [ $? -ne 0 ]; then
    echo "debootstrap执行失败，请检查错误信息。"
    exit 1
fi

# 挂载必要的文件系统
echo "挂载必要的文件系统..."
sudo mount --bind /dev "$TARGET_DIR/dev"
sudo mount --bind /proc "$TARGET_DIR/proc"
sudo mount --bind /sys "$TARGET_DIR/sys"

# 进入chroot环境
echo "进入chroot环境进行配置..."
sudochroot "$TARGET_DIR" /bin/bash <<EOF
# 更新软件源
echo "更新软件源..."
cat > /etc/apt/sources.list <<EOL
deb $MIRROR $DEBIAN_VERSION main contrib non-free
deb-src $MIRROR $DEBIAN_VERSION main contrib non-free
EOL

# 更新包列表
apt update

# 安装常用的软件包
echo "安装常用的软件包..."
apt install -y vim sudo openssh-server locales

# 设置时区
echo "设置时区为Asia/Shanghai..."
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# 设置语言环境
echo "设置语言环境为en_US.UTF-8..."
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# 创建用户
echo "创建用户$USERNAME..."
adduser --disabled-password --gecos "" "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

# 添加用户到sudo组
usermod -aG sudo "$USERNAME"

# 配置SSH
echo "配置SSH..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart

# 清理
apt clean
EOF

# 卸载挂载的文件系统
echo "卸载挂载的文件系统..."
sudo umount "$TARGET_DIR/dev"
sudo umount "$TARGET_DIR/proc"
sudo umount "$TARGET_DIR/sys"

echo "Debian系统构建完成！目标目录为$TARGET_DIR"

}


update_init_status() {
    local status=$1
    echo "CONFIG_INIT_STATUS=$status" > "$INIT_CONFIG_FILE"
}

# 更新工具链状态为已完成
update_toolchain_status() {
    local status=$1
    echo "TOOLCHAIN_STATUS=$status" >> "$INIT_CONFIG_FILE"
}

# 更新工具链状态为已完成
update_kernel_status() {
    local status=$1
    echo "KERNEL_STATUS=$status" >> "$INIT_CONFIG_FILE"
}

update_rootfs_status() {
    local status=$1
    echo "ROOTFS_STATUS=$status" >> "$INIT_CONFIG_FILE"
}

check_env(){

    if [ -d "$UBOOT_PATH" ]; then
        # 如果存在，更新 CONFIG_INIT_STATUS 为 y
        echo "U-BOOT 已存在，更新配置文件。"
        update_init_status y
    else
        # 如果不存在，更新 CONFIG_INIT_STATUS 为 n
        echo "U-BOOT 不存在，更新配置文件。"
        update_init_status n
    fi
    if [ -f "/usr/bin/python" ]; then
        # 如果存在，更新 CONFIG_INIT_STATUS 为 y
        echo "python env is ok!"
     
    else
        # 如果不存在，更新 CONFIG_INIT_STATUS 为 n
        echo "Set python"
        sudo ln -s /usr/bin/python2 /usr/bin/python
    fi


    if [ -d "$TOOlCHAIN_PATH" ]; then
        # 如果存在，更新 TOOLCHAIN_STATUS 为 y
        echo "TOOLCHAIN 已存在，更新配置文件。"
        update_toolchain_status y
    else
        # 如果不存在，更新 TOOLCHAIN_STATUS 为 n
        echo "TOOLCHAIN 不存在，更新配置文件。"
        update_toolchain_status n
    fi

    if [ -d "$KERNEL_PATH" ]; then
        # 如果存在，更新 KERNEL_STATUS 为 y
        echo "kernel 已存在，更新配置文件。"
        update_kernel_status y
    else
        # 如果不存在，更新 KERNEL_STATUS 为 n
        echo "kernel 不存在，更新配置文件。"
        update_kernel_status n
    fi

    if [ -d "$ROOTFS_PATH" ]; then
        # 如果存在，更新 KERNEL_STATUS 为 y
        echo "rootfs已存在，更新配置文件。"
        update_rootfs_status y
    else
        # 如果不存在，更新 KERNEL_STATUS 为 n
        echo "rootfs 不存在，更新配置文件。"
        update_rootfs_status n
    fi

    if grep -q "$PROJERCT_PATH" "$ENV_PATH"; then
        echo " '$PROJERCT_PATH' 存在于文件 $ENV_PATH 中"
    else
        echo "'$PROJERCT_PATH' 不存在于文件 $ENV_PATH 中"
        sudo sh -c "echo \"export BANFIC_PATH=${PROJERCT_PATH}\" >> ${ENV_PATH}"
    fi

}
# 复制文件
copy_files() {
    cd $PROJERCT_PATH
    cp ./modify/dtc-lexer.lex.c  $UBOOT_PATH/scripts/dtc/dtc-lexer.lex.c
    cp ./modify/Makefile.lib    $UBOOT_PATH/scripts/Makefile.lib 
    cp ./modify/BanNano_defconfig $KERNEL_PATH/arch/arm/configs
}

# 配置函数
config() {

    echo "Get workable env..."
    sudo apt update
    sudo apt install u-boot-tools libssl-dev  bison flex debian-archive-keyring -y
    sudo apt-get install gcc make cmake rsync wget unzip build-essential git bc swig libncurses-dev libpython3-dev  --no-install-recommends -y
    sudo apt-get install libssl-dev python3-distutils android-tools-mkbootimg python2-dev debootstrap qemu qemu-user-static binfmt-support dpkg-cross -y

    echo "执行配置任务..."

    check_env

    echo "INIT_CONFIG_FILE: $INIT_CONFIG_FILE"
    cat "$INIT_CONFIG_FILE"

    local init_status=$(check_init_status)
    local toolchain_status=$(check_toolchain_status)
    local kernel_status=$(check_kernel_status)
    local rootfs_status=$(check_rootfs_status)

    # 在这里添加配置相关的命令
    if [ "$init_status" = "y" ]; then
          echo "U-BOOT Ready finish!，跳过。"
    else
        echo "开始解压..."
        extract_uboot
        echo "初始化完成，已更新配置文件。"
    fi


    
    if [ "$toolchain_status" = "y" ]; then
                echo "工具链已下载，跳过下载步骤。"
    else
        echo "Download toolchain..."
        download_and_extract_toolchain
        echo "Download finished。"
    fi
    

    if [ "$kernel_status" = "y" ]; then
                echo "Kernel已下载，跳过下载步骤。"i
    else
        echo "Download kernel..."
        extract_kernel
        echo "finished!"
    fi

    if [ "$rootfs_status" = "y" ]; then
        echo "rootfs is ok，跳过步骤。"i
    else
        echo "$ROOTFS_NAME readying..."
        ready_rootfs
        echo "finished!"
    fi

    source /etc/profile
    arm-linux-gnueabi-gcc -v

    echo "开始复制文件..."
    copy_files
    
    echo "文件复制完成。"
}

# 编译 U-Boot 函数
make_uboot() {
    
    # 在这里添加编译 U-Boot 的命令
    echo "开始编译 U-Boot..."
    cd $UBOOT_PATH
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- licheepi_nano_defconfig
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j4
    cp u-boot-sunxi-with-spl.bin $PROJERCT_PATH/../out/ 


    
}

# 编译内核函数
make_kernel() {
    
    echo "开始编译内核..."
    cd $KERNEL_PATH
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- BanNano_defconfig
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j4
    cp arch/arm/boot/zImage $PROJERCT_PATH/../out
    cp arch/arm/boot/dts/suniv-f1c100s-licheepi-nano.dtb $PROJERCT_PATH/../out/$DTB_NAME
    
    
}

# 编译内核函数
pack_rootfs() {
    
  
    cd $PROJERCT_PATH/../
    echo "开始打包......"
    sudo tar -cSf rootfs_$ROOTFS_NAME.tar -C $ROOTFS_NAME .
    mkdir -p ./out
    sudo mv rootfs_$ROOTFS_NAME.tar ./out

}

# 清理 U-Boot 函数
clean_uboot() {
    echo "清理 U-Boot..."
    cd $UBOOT_PATH
    make clean
    make distclean
    # 在这里添加清理 U-Boot 的命令
}

# 清理内核函数
clean_kernel() {
    echo "清理内核..."
    # 在这里添加清理内核的命令
}

# 清理所有函数
clean_all() {
    clean_uboot
    clean_kernel
    echo "清理完成。"
}

to_git() {
    echo "Get env to git..."
    cd $PROJERCT_PATH
    sudo rm -r ./download/* 
    sudo rm init_config.defconfig
    
}

make_img (){

cd $PROJERCT_PATH/../out

touch boot.cmd

# 向 boot.cmd 文件中写入内容
cat > boot.cmd <<EOF
setenv bootargs console=tty0 console=ttyS0,115200 panic=5 rootwait root=/dev/mmcblk0p2 rw 
load mmc 0:1 0x80C00000 $DTB_NAME
load mmc 0:1 0x80008000 zImage
bootz 0x80008000 - 0x80C00000
EOF

# 创建空的.img文件
echo "创建空的.img文件..."
dd if=/dev/zero of="$IMG_FILE" bs=1M count=0 seek=$(echo "$IMG_SIZE" | sed 's/G/*1024/' | bc)

# 使用fdisk划分分区
echo "划分分区..."
fdisk "$IMG_FILE" <<EOF
o
n
p
1
$(($PART1_OFFSET / 512))
+$(($PART1_SIZE / 512))
n
p
2
$(($PART1_OFFSET / 512 + $PART1_SIZE / 512))
w
EOF

# 检查分区表
echo "分区表已创建，以下是分区信息："
fdisk -l "$IMG_FILE"

# 设置环回设备
echo "设置环回设备..."
LOOP_DEVICE=$(sudo losetup --find --show --partscan "$IMG_FILE")
PART1_DEVICE="${LOOP_DEVICE}p1"
PART2_DEVICE="${LOOP_DEVICE}p2"

# 格式化分区
echo "格式化第一个分区为FAT16..."
sudo mkfs.fat -F 16 "$PART1_DEVICE"

echo "格式化第二个分区为ext4..."
sudo mkfs.ext4 "$PART2_DEVICE"

# 挂载分区
echo "挂载分区..."
MOUNT_DIR1=$(mktemp -d)
MOUNT_DIR2=$(mktemp -d)
sudo mount "$PART1_DEVICE" "$MOUNT_DIR1"
sudo mount "$PART2_DEVICE" "$MOUNT_DIR2"

# 将文件拷贝到第一个分区
echo "将文件拷贝到第一个分区..."
sudo cp "$ZIMAGE_FILE" "$MOUNT_DIR1/"
sudo cp "$DTB_FILE" "$MOUNT_DIR1/"
sudo cp "$BOOT_SCR_FILE" "$MOUNT_DIR1/"

# 将rootfs.tar解压到第二个分区
echo "将rootfs.tar解压到第二个分区..."
sudo tar -xvf "$ROOTFS_TAR" -C "$MOUNT_DIR2"

# 卸载分区
echo "卸载分区..."
sudo umount "$MOUNT_DIR1"
sudo umount "$MOUNT_DIR2"
rmdir "$MOUNT_DIR1"
rmdir "$MOUNT_DIR2"

# 移除环回设备
echo "移除环回设备..."
sudo losetup -d "$LOOP_DEVICE"

echo "操作完成！"
# # 写入 U-Boot
sudo dd if=u-boot-sunxi-with-spl.bin of="$IMG_FILE" bs=1024 seek=8
sudo fdisk -l $IMG_FILE

}


pack() {
    echo "pack img..."

    pack_rootfs

    make_img 
    
   
}

all_in_one() {
    
   config
   make_uboot
   make_kernel
   pack
}
# 主函数
main() {
    


    case "$1" in
        config)
            config
            ;;
        make_uboot)
            make_uboot
            ;;
        make_kernel)
            make_kernel
            ;;
        clean_uboot)
            clean_uboot
            ;;
        clean_kernel)
            clean_kernel
            ;;
        clean_all)
            clean_all
            ;;
        to_git)
            to_git
            ;;

        to_git)
            pack
            ;;
        "")
            all_in_one
            ;;
        *)
            echo "无效的参数: $1"
            echo "可用的参数: config, make_uboot, make_kernel, clean_uboot, clean_kernel, clean_all"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
#!/bin/bash


# rkdeveloptool db rkxx_loader_vx.xx.bin
# rkdeveloptool wl 0x40 idbLoader.img
# rkdeveloptool wl 0x4000 uboot.itb
# rkdeveloptool wl 0x8000 boot.itb
# rkdeveloptool wl 0x40000 ubuntu_ext4.img

set -e
PROJERCT_PATH=$(pwd)
# 初始化配置文件路径
INIT_CONFIG_FILE="$PROJERCT_PATH/init_config.defconfig"
# 默认值
DEFAULT_INIT_STATUS=n
# TOOLCHAIN_STATUS=n
# KERNEL_STATUS=n
UBOOT_NAME="u-boot"
KERNEL_NAME="linux-5.7.1"
KERNEL_PATH="$PROJERCT_PATH/../$KERNEL_NAME"
UBOOT_PATH="$PROJERCT_PATH/../$UBOOT_NAME"

TOOlCHAIN_PATH="/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi"
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

# 下载并解压工具链
download_and_extract_toolchain() {
    echo "下载工具链"

    wget -P ./download http://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/arm-linux-gnueabi/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi.tar.xz

    tar -vxJf ./download/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi.tar.xz

    sudo mv  gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi /opt/

    # 将工具链路径写入 /etc/profile
    sudo sh -c 'echo "export PATH=\$PATH:/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi/bin" > /etc/profile'
  
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

}
# 复制文件
copy_files() {
    cd $PROJERCT_PATH
    cp ./modify/dtc-lexer.lex.c  $UBOOT_PATH/scripts/dtc/dtc-lexer.lex.c
    cp ./modify/Makefile.lib    $UBOOT_PATH/scripts/Makefile.lib 
}

# 配置函数
config() {

    echo "Get workable env..."
    sudo apt update
    sudo apt install u-boot-tools libssl-dev  bison flex -y
    sudo apt-get install gcc make cmake rsync wget unzip build-essential git bc swig libncurses-dev libpython3-dev libssl-dev python3-distutils android-tools-mkbootimg python2-dev -y

    echo "执行配置任务..."

    check_env

    echo "INIT_CONFIG_FILE: $INIT_CONFIG_FILE"
    cat "$INIT_CONFIG_FILE"

    local init_status=$(check_init_status)
    local toolchain_status=$(check_toolchain_status)
    local kernel_status=$(check_kernel_status)

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
                echo "工具链已下载，跳过下载步骤。"i
    else
        echo "Download kernel..."
        extract_kernel
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
    
    echo "开始编译 U-Boot..."
    cd $UBOOT_PATH
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- licheepi_nano_defconfig
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j4

    # 在这里添加编译 U-Boot 的命令
}

# 编译内核函数
make_kernel() {
    
    echo "开始编译内核..."
    cd $KERNEL_PATH
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- licheepi_nano_defconfig
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j4

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

pack() {
    echo "pack img..."
    cd $PROJERCT_PATH

    
   
}

all_in_one() {
    
   config
   make_uboot
   make_kernel
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
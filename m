#!/bin/bash
#
# by Minhker
# MK Build Script V8

# Main Dir
MK_DIR=$(pwd)
MK_KERNEL=$MK_DIR/arch/arm64/boot/Image
MK_DTBO=$MK_DIR/arch/arm64/boot/dtbo.img
MK_DTB=$MK_DIR/arch/arm64/boot/dt.img
# Kernel Name and Version
MK_VERSION=V15.1_Freq2080
MK_NAME=MinhKer_R
# Thread count
MK_JOBS=5
# Current Date
MK_DATE=$(date +%Y%m%d)

echo "Setting Up Environment"
echo ""
export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=r
export PLATFORM_VERSION=11.0.0

# CCACHE
export CCACHE="$(which ccache)"
export USE_CCACHE=1
ccache -M 20G
export CCACHE_COMPRESS=1

export CROSS_COMPILE=/home/m/kernel/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CLANG_TRIPLE=/home/m/kernel/toolchain/clang/host/linux-x86/clang-4639204/bin/aarch64-linux-gnu-
export CC=/home/m/kernel/toolchain/clang/host/linux-x86/clang-4639204/bin/clang

##########################################

MK_CONFG_A305=exynos7885-a30v3_defconfig
MK_VARIANT_A305=A305
# Script functions

read -p "Clean source (y/n) > " yn
if [ "$yn" = "Y" -o "$yn" = "y" ]; then
     echo "Clean Build"    
     make clean && make mrproper 
	rm ./arch/arm64/boot/Image
	rm ./arch/arm64/boot/Image.gz
	rm ./Image  
else
     echo "okey will build kernel"         
fi

BUILD_ZIMAGE()
{
	echo "Building zImage for $MK_VARIANT"
	export LOCALVERSION=-$MK_NAME-$MK_VERSION-$MK_VARIANT-$MK_DATE
	make  $MK_CONFG
	make -j$MK_JOBS
	if [ ! -e ./arch/arm64/boot/Image ]; then
	exit 0;
	echo "zImage Failed to Compile"
	echo " Abort "
	fi
	echo " "
	echo "----------------------------------------------"
}
PACK_BOOT_IMG()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building Boot.img for $MK_VARIANT"
	cp -rf $MK_RAMDISK/* $MK_AIK
   	 cp -rf $MK_RAMDISK/* $MK_AIK
	cp $MK_KERNEL /home/m/share/KERNEL/MinhKer_kernel_R_a30_v14.4_pro/Image
	mv $MK_KERNEL $MK_AIK/split_img/boot.img-zImage
	$MK_AIK/repackimg.sh
	# Remove red warning at boot
	echo -n "SEANDROIDENFORCE" » $MK_AIK/image-new.img
	echo "coping boot.img... to..."
	#cp $MK_AIK/image-new.img  /home/m/share/KERNEL/MINHKA_kernel_R_a30_v14.3_pro/boot.img
	$MK_AIK/cleanup.sh
	#pass my ubuntu Lerov-vv
}
# Main Menu
clear
echo "----------------------------------------------"
echo "$MK_NAME $MK_VERSION Build Script"
echo "----------------------------------------------"
PS3='Please select your option (1-x): '
menuvar=( "SM-A305"  "Exit")
select menuvar in "${menuvar[@]}"
do
    case $menuvar in
       
	"SM-A305")
             clear
            echo "Starting $MK_VARIANT_A305 kernel build..."
            MK_VARIANT=$MK_VARIANT_A305
            MK_CONFG=$MK_CONFG_A305
            BUILD_ZIMAGE
	    cp $MK_KERNEL /home/m/kernel/a30_exynos_R_oc/MK/MinhKer_kernel_R_a30_v15.1_Pro/Image
	    cp $MK_DTBO /home/m/kernel/a30_exynos_R_oc/MK/MinhKer_kernel_R_a30_v15.1_Pro/dtbo.img
	    cp $MK_DTB /home/m/kernel/a30_exynos_R_oc/MK/MinhKer_kernel_R_a30_v15.1_Pro/dtb.img
	    echo "Packing zip"
	    echo "=========================="
	    cd MK/MinhKer_kernel_R_a30_v15.1_Pro
	    ./zip.sh
	    cd ../..
	    cp -r /home/m/kernel/a30_exynos_R_oc/MK/MinhKer_kernel_R_a30_v15.1_Pro /home/m/share/KERNEL
	    echo "$MK_VARIANT kernel dtbo dtb build and coppy finished."
	    break
            ;;
        "Exit")
            break
            ;;
        *) echo Invalid option.;;
	          
    esac
done

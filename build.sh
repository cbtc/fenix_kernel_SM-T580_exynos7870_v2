#!/bin/bash
# kernel build script by Tkkg1994 v0.4 (optimized from apq8084 kernel source)
# Modified by Siddhant / XDA Developers

# ---------
# VARIABLES
# ---------
BUILD_SCRIPT=1.2
VERSION_NUMBER=$(<build/version)
ARCH=arm64
BUILD_CROSS_COMPILE=/home/carlos/kernel/toolchains/aarch64-linux-android-5.3-kernel/bin/aarch64-linux-android-
BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
PAGE_SIZE=2048
DTB_PADDING=0
KERNELNAME=Lazer_Kernel
KERNELCONFIG=Lazer_Kernel
ZIPLOC=zip
RAMDISKLOC=ramdisk

# ---------
# FUNCTIONS
# ---------
FUNC_CLEAN()
{
make clean
make ARCH=arm64 distclean
rm -f $RDIR/build/build.log
rm -f $RDIR/build/build-G610x.log
rm -f $RDIR/build/build-J710x.log
rm -rf $RDIR/arch/arm64/boot/dtb
rm -f $RDIR/arch/$ARCH/boot/dts/*.dtb
rm -f $RDIR/arch/$ARCH/boot/boot.img-zImage
rm -f $RDIR/build/boot.img
rm -f $RDIR/build/*.zip
rm -f $RDIR/build/$RAMDISKLOC/G610x/image-new.img
rm -f $RDIR/build/$RAMDISKLOC/G610x/ramdisk-new.cpio.gz
rm -f $RDIR/build/$RAMDISKLOC/G610x/split_img/boot.img-zImage
rm -f $RDIR/build/$RAMDISKLOC/G610x/image-new.img
rm -f $RDIR/build/$RAMDISKLOC/J710x/ramdisk-new.cpio.gz
rm -f $RDIR/build/$RAMDISKLOC/J710x/split_img/boot.img-zImage
rm -f $RDIR/build/$ZIPLOC/G610x/*.zip
rm -f $RDIR/build/$ZIPLOC/G610x/*.img
rm -f $RDIR/build/$ZIPLOC/J710x/*.zip
rm -f $RDIR/build/$ZIPLOC/J710x/*.img
echo "" > $RDIR/build/$RAMDISKLOC/G610x/ramdisk/acct/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/G610x/ramdisk/cache/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/G610x/ramdisk/data/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/G610x/ramdisk/dev/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/G610x/ramdisk/lib/modules/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/G610x/ramdisk/mnt/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/G610x/ramdisk/proc/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/G610x/ramdisk/storage/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/G610x/ramdisk/sys/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/G610x/ramdisk/system/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/J710x/ramdisk/acct/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/J710x/ramdisk/cache/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/J710x/ramdisk/data/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/J710x/ramdisk/dev/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/J710x/ramdisk/lib/modules/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/J710x/ramdisk/mnt/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/J710x/ramdisk/proc/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/J710x/ramdisk/storage/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/J710x/ramdisk/sys/.placeholder
echo "" > $RDIR/build/$RAMDISKLOC/J710x/ramdisk/system/.placeholder
}

FUNC_DELETE_PLACEHOLDERS()
{
find . -name \.placeholder -type f -delete
echo "Placeholders Deleted from Ramdisk"
echo ""
}

FUNC_BUILD_ZIMAGE()
{
echo ""
echo "build common config="$KERNEL_DEFCONFIG ""
echo "build variant config="$MODEL ""
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	$KERNEL_DEFCONFIG || exit -1
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
echo ""
}

FUNC_BUILD_RAMDISK()
{

if [ ! -f "$RDIR/build/ramdisk/G610x/ramdisk/config" ]; then
	mkdir $RDIR/build/ramdisk/G610x/ramdisk/config
	chmod 500 $RDIR/build/ramdisk/G610x/ramdisk/config
fi
if [ ! -f "$RDIR/build/ramdisk/J710x/ramdisk/config" ]; then
	mkdir $RDIR/build/ramdisk/J710x/ramdisk/config
	chmod 500 $RDIR/build/ramdisk/J710x/ramdisk/config
fi

mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
case $MODEL in
gtaxlwifi)
	rm -f $RDIR/build/ramdisk/G610x/split_img/boot.img-zImage
	mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/build/ramdisk/G610x/split_img/boot.img-zImage
	cd $RDIR/build/ramdisk/G610x
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img
	;;
j7xelte)
	rm -f $RDIR/build/ramdisk/J710x/split_img/boot.img-zImage
	mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/build/ramdisk/J710x/split_img/boot.img-zImage
	cd $RDIR/build/ramdisk/J710x
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img
	;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
esac
}

FUNC_BUILD_BOOTIMG()
{
	(
	FUNC_BUILD_ZIMAGE
	FUNC_BUILD_RAMDISK
	) 2>&1	 | tee -a $RDIR/build/build.log
}

FUNC_BUILD_ZIP()
{
echo ""
echo "Building Zip File"
cd $ZIP_FILE_DIR
zip -gq $ZIP_NAME -r META-INF/ -x "*~"
zip -gq $ZIP_NAME -r system/ -x "*~" 
[ -f "$RDIR/build/$ZIPLOC/G610x/boot.img" ] && zip -gq $ZIP_NAME boot.img -x "*~"
[ -f "$RDIR/build/$ZIPLOC/J710x/boot.img" ] && zip -gq $ZIP_NAME boot.img -x "*~"
if [ -n `which java` ]; then
	echo "Java Detected, Signing Zip File"
	mv $ZIP_NAME old$ZIP_NAME
	java -Xmx1024m -jar $RDIR/build/signapk/signapk.jar -w $RDIR/build/signapk/testkey.x509.pem $RDIR/build/signapk/testkey.pk8 old$ZIP_NAME $ZIP_NAME
	rm old$ZIP_NAME
fi
chmod a+r $ZIP_NAME
mv -f $ZIP_FILE_TARGET $RDIR/build/$ZIP_NAME
cd $RDIR
}

OPTION_1()
{
rm -f $RDIR/build/build.log
MODEL=gtaxlwifi
KERNEL_DEFCONFIG=exynos7870-gtaxlwifi_eur_open_defconfig
START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a $RDIR/build/build.log
mv -f $RDIR/build/ramdisk/G610x/image-new.img $RDIR/build/boot.img
mv -f $RDIR/build/build.log $RDIR/build/build-G610x.log
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
echo "You can now find your boot.img in the build folder"
echo "You can now find your build-G610x.log file in the build folder"
echo ""
}

OPTION_2()
{
rm -f $RDIR/build/build.log
MODEL=j7xelte
KERNEL_DEFCONFIG=Lazer_Kernel_j7xelte_defconfig
START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a $RDIR/build/build.log
mv -f $RDIR/build/ramdisk/J710x/image-new.img $RDIR/build/boot.img
mv -f $RDIR/build/build.log $RDIR/build/build-J710x.log
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
echo "You can now find your boot.img in the build folder"
echo "You can now find your build-J710x.log file in the build folder"
echo ""
}

OPTION_3()
{
rm -f $RDIR/build/build.log
MODEL=on7xelte
KERNEL_DEFCONFIG=Lazer_Kernel_on7xelte_defconfig
START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a $RDIR/build/build.log
mv -f $RDIR/build/ramdisk/G610x/image-new.img $RDIR/build/G610x.img-save
mv -f $RDIR/build/build.log $RDIR/build/build-G610x.log-save
MODEL=j7xelte
KERNEL_DEFCONFIG=Lazer_Kernel_j7xelte_defconfig
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a $RDIR/build/build.log
mv -f $RDIR/build/G610x.img-save $RDIR/build/G610x.img
mv -f $RDIR/build/ramdisk/J710x/image-new.img $RDIR/build/J710x.img
mv -f $RDIR/build/build-G610x.log-save $RDIR/build/build-G610x.log
mv -f $RDIR/build/build.log $RDIR/build/build-J710x.log
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
echo "You can now find your G610x.img in the build folder"
echo "You can now find your J710x.img in the build folder"
echo "You can now find your build-G610x.log file in the build folder"
echo "You can now find your build-J710x.log file in the build folder"
echo ""
}

OPTION_4()
{
rm -f $RDIR/build/build.log
MODEL=on7xelte
KERNEL_DEFCONFIG=Lazer_Kernel_on7xelte_defconfig
START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a $RDIR/build/build.log
mv -f $RDIR/build/ramdisk/G610x/image-new.img $RDIR/build/$ZIPLOC/G610x/boot.img
mv -f $RDIR/build/build.log $RDIR/build/build-G610x.log
ZIP_DATE=`date +%Y%m%d`
ZIP_FILE_DIR=$RDIR/build/$ZIPLOC/G610x
ZIP_NAME=$KERNELNAME.G610x.v$VERSION_NUMBER.$ZIP_DATE.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
FUNC_BUILD_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
echo "You can now find your .zip file in the build folder"
echo "You can now find your build-G610x.log file in the build folder"
echo ""
}

OPTION_5()
{
rm -f $RDIR/build/build.log
MODEL=j7xelte
KERNEL_DEFCONFIG=Lazer_Kernel_j7xelte_defconfig
START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a $RDIR/build/build.log
mv -f $RDIR/build/ramdisk/J710x/image-new.img $RDIR/build/$ZIPLOC/J710x/boot.img
mv -f $RDIR/build/build.log $RDIR/build/build-J710x.log
ZIP_DATE=`date +%Y%m%d`
ZIP_FILE_DIR=$RDIR/build/$ZIPLOC/J710x
ZIP_NAME=$KERNELNAME.J710x.v$VERSION_NUMBER.$ZIP_DATE.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
FUNC_BUILD_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
echo "You can now find your .zip file in the build folder"
echo "You can now find your build-J710x.log file in the build folder"
echo ""
}

OPTION_6()
{
rm -f $RDIR/build/build.log
MODEL=on7xelte
KERNEL_DEFCONFIG=Lazer_Kernel_on7xelte_defconfig
START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a $RDIR/build/build.log
mv -f $RDIR/build/ramdisk/G610x/image-new.img $RDIR/build/$ZIPLOC/G610x/boot.img-save
mv -f $RDIR/build/build.log $RDIR/build/build-G610x.log-save
MODEL=j7xelte
KERNEL_DEFCONFIG=Lazer_Kernel_j7xelte_defconfig
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a $RDIR/build/build.log
mv -f $RDIR/build/$ZIPLOC/G610x/boot.img-save $RDIR/build/$ZIPLOC/G610x/boot.img
mv -f $RDIR/build/ramdisk/J710x/image-new.img $RDIR/build/$ZIPLOC/J710x/boot.img
mv -f $RDIR/build/build-G610x.log-save $RDIR/build/build-G610x.log
mv -f $RDIR/build/build.log $RDIR/build/build-J710x.log
ZIP_DATE=`date +%Y%m%d`
ZIP_FILE_DIR=$RDIR/build/$ZIPLOC/G610x
ZIP_NAME=$KERNELNAME.G610x.v$VERSION_NUMBER.$ZIP_DATE.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
FUNC_BUILD_ZIP
ZIP_FILE_DIR=$RDIR/build/$ZIPLOC/J710x
ZIP_NAME=$KERNELNAME.J710x.v$VERSION_NUMBER.$ZIP_DATE.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
FUNC_BUILD_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
echo "You can now find your .zip files in the build folder"
echo "You can now find your build-G610x.log file in the build folder"
echo "You can now find your build-J710x.log file in the build folder"
echo ""
}

OPTION_7()
{
rm -f $RDIR/build/build.log
MODEL=on7xelte
KERNEL_DEFCONFIG=Lazer_Kernel_on7xelte_defconfig
START_TIME=`date +%s`
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a $RDIR/build/build.log
mv -f $RDIR/build/ramdisk/G610x/image-new.img $RDIR/build/$ZIPLOC/g93xx/G610x.img-save
mv -f $RDIR/build/build.log $RDIR/build/build-G610x.log-save
MODEL=j7xelte
KERNEL_DEFCONFIG=Lazer_Kernel_j7xelte_defconfig
	(
	FUNC_BUILD_BOOTIMG
	) 2>&1	 | tee -a $RDIR/build/build.log
mv -f $RDIR/build/$ZIPLOC/g93xx/G610x.img-save $RDIR/build/$ZIPLOC/g93xx/G610x.img
mv -f $RDIR/build/ramdisk/J710x/image-new.img $RDIR/build/$ZIPLOC/g93xx/J710x.img
mv -f $RDIR/build/build-G610x.log-save $RDIR/build/build-G610x.log
mv -f $RDIR/build/build.log $RDIR/build/build-J710x.log
ZIP_DATE=`date +%Y%m%d`
ZIP_FILE_DIR=$RDIR/build/$ZIPLOC/g93xx
ZIP_NAME=$KERNELNAME.G93xx.v$VERSION_NUMBER.$ZIP_DATE.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
FUNC_BUILD_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
echo "You can now find your .zip file in the build folder"
echo "You can now find your build-G610x.log file in the build folder"
echo "You can now find your build-J710x.log file in the build folder"
echo ""
}

OPTION_0()
{
echo "Cleaning Workspace"
FUNC_CLEAN
}

# ----------------------------------
# CHECK COMMAND LINE FOR ANY ENTRIES
# ----------------------------------
if [ $1 == 0 ]; then
	OPTION_0
fi
if [ $1 == 1 ]; then
	OPTION_1
fi
if [ $1 == 2 ]; then
	OPTION_2
fi
if [ $1 == 3 ]; then
	OPTION_3
fi
if [ $1 == 4 ]; then
	OPTION_4
fi
if [ $1 == 5 ]; then
	OPTION_5
fi
if [ $1 == 6 ]; then
	OPTION_6
fi
if [ $1 == 7 ]; then
	OPTION_7
fi

# -------------
# PROGRAM START
# -------------
rm -rf ./build/build.log
clear
echo "Lazer_Kernel J7 Build Script v$BUILD_SCRIPT -- Kernel Version: v$VERSION_NUMBER"
echo ""
echo " 0) Clean Workspace"
echo ""
echo " 1) Build Lazer_Kernel boot.img for J7 Prime"
echo " 2) Build Lazer_Kernel boot.img for J7 2016"
echo " 3) Build Lazer_Kernel boot.img for J7 Prime + J7 2016"
echo " 4) Build Lazer_Kernel boot.img and .zip for J7 Prime"
echo " 5) Build Lazer_Kernel boot.img and .zip for J7 2016"
echo " 6) Build Lazer_Kernel boot.img and .zip for J7 Prime + J7 2016 (Seperate)"
echo " 7) Build Lazer_Kernel boot.img and .zip for J7 Prime + J7 2016 (All-In-One)"
echo ""
echo " 9) Exit"
echo ""
read -p "Please select an option " prompt
echo ""
if [ $prompt == "0" ]; then
	OPTION_0
	echo ""
	echo ""
	echo ""
	echo ""
	./build.sh
elif [ $prompt == "1" ]; then
	OPTION_1
	echo ""
	echo ""
	echo ""
	echo ""
	read -n 1 -s -p "Press any key to continue"
elif [ $prompt == "2" ]; then
	OPTION_2
	echo ""
	echo ""
	echo ""
	echo ""
	read -n 1 -s -p "Press any key to continue"
elif [ $prompt == "3" ]; then
	OPTION_3
	echo ""
	echo ""
	echo ""
	echo ""
	read -n 1 -s -p "Press any key to continue"
elif [ $prompt == "4" ]; then
	OPTION_4
	echo ""
	echo ""
	echo ""
	echo ""
	read -n 1 -s -p "Press any key to continue"
elif [ $prompt == "5" ]; then
	OPTION_5
	echo ""
	echo ""
	echo ""
	echo ""
	read -n 1 -s -p "Press any key to continue"
elif [ $prompt == "6" ]; then
	OPTION_6
	echo ""
	echo ""
	echo ""
	echo ""
	read -n 1 -s -p "Press any key to continue"
elif [ $prompt == "7" ]; then
	OPTION_7
	echo ""
	echo ""
	echo ""
	echo ""
	read -n 1 -s -p "Press any key to continue"
elif [ $prompt == "9" ]; then
	exit
fi

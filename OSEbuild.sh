#! /bin/bash
#################################################
#                OSEbuild Android
#################################################
# Configure where we can find things here
#################################################
#          on&off
BUILD_LOG="on"
BACKUP="on"
#
#################################################
#             ANDROID NDK
###                 on&off
ANDROID_NDK_AU_DOWNLOAD="on"
ANDROID_NDK_REV="r13b"
### ANDROID_NDK_AU_DOWNLOAD = off ##
ANDROID_NDK_ROOT=$PWD/../android-ndk
#################################################
#
ANDROID_API_LEVEL="19"
TOOLCHAIN_VERSION="4.9"
####
OPENSSL_VERSION="1.0.2m"
LIBUSB_VERSION="1.0.20"
##############
PCSC_ANDROID="on";
PCSC_LITE_VERSION="1.8.22"
PCSC_APP_DIR="/data/data/osebuild.pcsc"
##############
CCID_ANDROID="on"
CCID_VERSION="1.4.28"
#################################################
# end ###########################################
#################################################
SOURCEDIR="tmp"
###############################################################
progressbox="dialog --stdout ""$1"" --progressbox 15 70";
[ ! -e $SOURCEDIR ] && mkdir -p $SOURCEDIR;
ddir=`pwd`;
cd $SOURCEDIR
rdir=`pwd`;
btdir="$rdir/toolchains/backup";
date=`date`
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} = 'x86_64' ]; then
M_TYPE="x86_64"
else
M_TYPE="x86"
fi
####
android(){
if [ "$ANDROID_API_LEVEL" -ge "16" ]; then
PIE="-fPIE"
PIE_="-fPIE -pie"
else
PIE=""
PIE_=""
fi
CFLAGS="-g -DANDROID -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes $CFLAGS $PIE"
LDFLAGS="-Wl,--build-id -Wl,--warn-shared-textrel -Wl,--fatal-warnings $LDFLAGS $PIE_"      
case "$ARCH" in
arm)
Toolchain="arm-linux-androideabi"
PLATFORM="arm-linux-androideabi"
;;
x86)
Toolchain="x86"
PLATFORM="i686-linux-android"
;;
mips)
Toolchain="mipsel-linux-android"
PLATFORM="mipsel-linux-android"
;;
arm64)
Toolchain="aarch64-linux-android"
PLATFORM="aarch64-linux-android"
;;
 x86_64)
Toolchain="x86_64"
PLATFORM="x86_64-linux-android"
;;
mips64)
Toolchain="mips64el-linux-android"
PLATFORM="mips64el-linux-android"
;;
esac
tcdir="$rdir/toolchains/$Toolchain-api-$ANDROID_API_LEVEL"
CONF="/usr/local/etc";
Build="android-api-$ANDROID_API_LEVEL-$ARCH"
usb="libusb "USB_devices" off";
if [ "$PCSC_ANDROID" = "on" ] ; then
pcsc="pcsc "PCSC_readers" off";
else
pcsc="";
fi
ANDROID_NDK
CONFIG
OSCAM_MAKE
CFLAGS="";
LDFLAGS="";
}
####
CONFIG(){
CROSS=$CROSS;
cd $rdir/$CAM_F
REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2)
I_LIBCRYPTO="";
N_SSL="";
I_SSL="";
N_LIBUSB="";
I_LIBUSB="";
N_PCSC="";
I_PCSC="";
I_USE="";
N_USE="";
if [ -e $rdir/$CAM_F/stapi/liboscam_stapi5.a ] ; then
use='USE_STAPI5=1' 
use_="-stapi5"
us="$use_ "$use_" off"
else
use='' 
use_=""
us=""
fi
cmd=(dialog --separate-output --no-cancel --checklist "$CAM_F $REV: ($Build: $ABI)" 16 60 10)
options=(conf_dir: "$CONF" off	
	ssl "SSL" off
	$usb
	$pcsc
	$us
	libcrypt "LIBCRYPTO" on)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
for choice in $choices
do
	case $choice in
	conf_dir:)
	CONF=$(dialog --no-cancel --title "Oscam config dir:" --inputbox $CONF 8 30 $CONF 3>&1 1>&2 2>&3)
	;;
	libcrypt)
	I_LIBCRYPTO=" USE_LIBCRYPTO=1"
	;;
	ssl)
	N_SSL="-ssl";
	I_SSL=" USE_SSL=1";
	;;
	libusb)
	N_LIBUSB="-libusb";	
	I_LIBUSB=" USE_LIBUSB=1 LIBUSB_LIB=${tcdir}/sysroot/usr/lib/libusb-1.0.a";
	;;
	pcsc)
	N_PCSC="-pcsc"
	I_PCSC=" USE_PCSC=1 PCSC_LIB="-lpcsclite" EXTRA_FLAGS="-I${tcdir}/sysroot/usr/include/PCSC" EXTRA_LDFLAGS="-L${tcdir}/sysroot/usr/lib"";
	;;
	$use_)
	N_USE="$use_";
	I_USE=" $use";
	;;
	esac
done
make config
}
####
OSCAM_MAKE(){
CAMNAME=oscam-1.20-unstable_svn-${REV}${NP}-${Build}${N_SSL}${N_LIBUSB}${N_PCSC}${N_USE}
SMARGONAME=list_smargo-1.20-unstable_svn-${REV}${NP}-${Build}${N_SSL}${N_LIBUSB}${N_PCSC}${N_USE}
if [ "$N_LIBUSB" = "-libusb" ] ; then
smargo=" LIST_SMARGO_BIN=Distribution/${SMARGONAME}";
else
smargo="";
fi
if [ "$BUILD_LOG" = "on" ] ; then
case "$ANDROID_API_LEVEL" in
15)PLATFORM_VERSIONS="Android 4.0.3–4.0.4 Ice Cream Sandwich";;
16)PLATFORM_VERSIONS="Android 4.1 Jelly Bean";;
17)PLATFORM_VERSIONS="Android 4.2 Jelly Bean";;
18)PLATFORM_VERSIONS="Android 4.3 Jelly Bean";;
19)PLATFORM_VERSIONS="Android 4.4 KitKat";;
20)PLATFORM_VERSIONS="Android Wear 4.4 KitKat";;
21)PLATFORM_VERSIONS="Android 5.0 Lollipop";;
22)PLATFORM_VERSIONS="Android 5.1 Lollipop";;
23)PLATFORM_VERSIONS="Android 6.0 Marshmallow";;
24)PLATFORM_VERSIONS="Android 7.0 Nougat";;
25)PLATFORM_VERSIONS="Android 7.1 Nougat";;
26)PLATFORM_VERSIONS="Android 8.0 Oreo";;
27)PLATFORM_VERSIONS="Android 8.1 Oreo";;
esac
echo -e "-------------------------------------------">>$rdir/$CAM_F/Distribution/build.log;
echo -e "             $0">>$rdir/$CAM_F/Distribution/build.log;
echo -e "------------------------------------------">>$rdir/$CAM_F/Distribution/build.log;
echo -e "OSCAM$NP-Rev:$FILE_REV-$Build ">>$rdir/$CAM_F/Distribution/build.log;
echo -e "$PLATFORM_VERSIONS $ABI ">>$rdir/$CAM_F/Distribution/build.log;
echo -e "------------------------------------------">>$rdir/$CAM_F/Distribution/build.log;
#echo -e "make android-arm CROSS=${CROSS} OSCAM_BIN=Distribution/${CAMNAME}${smargo} CONF_DIR=${CONF}${I_LIBCRYPTO}${I_SSL}${I_LIBUSB}${I_PCSC}${I_USE}">>$rdir/$CAM_F/Distribution/build.log;
echo -e "Enabled configuration --------------------">>$rdir/$CAM_F/Distribution/build.log;
./config.sh -s 2>&1 | tee -a "$rdir/$CAM_F/Distribution/build.log" | $progressbox
make android-arm CROSS=${CROSS} OSCAM_BIN=Distribution/${CAMNAME}${smargo} CONF_DIR=${CONF} CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"${I_LIBCRYPTO}${I_SSL}${I_LIBUSB}${I_PCSC}${I_USE} 2>&1 |tee -a "$rdir/$CAM_F/Distribution/build.log" | $progressbox
echo -e "------------------------------------------">>$rdir/$CAM_F/Distribution/build.log;
echo -e "$date">>$rdir/$CAM_F/Distribution/build.log;
echo -e "------------------------------------------">>$rdir/$CAM_F/Distribution/build.log;
else
make android-arm CROSS=${CROSS} OSCAM_BIN=Distribution/${CAMNAME}${smargo} CONF_DIR=${CONF} CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"${I_LIBCRYPTO}${I_SSL}${I_LIBUSB}${I_PCSC}${I_USE} 2>&1 | $progressbox
fi
sleep 2
if [ ! -e $rdir/$CAM_F/Distribution/$CAMNAME ] ; then
dialog --title "WARNING!" --msgbox "\n                     BUILD ERROR!" 7 60
else
ZIP | $progressbox
dialog --title "$REV${NP}-$Build" --msgbox "\n $CAMNAME" 7 60
fi
}
####
ZIP(){
zip -j $ddir/$CAMNAME.zip -xi $rdir/$CAM_F/Distribution/$CAMNAME
[ "$N_LIBUSB" = "-libusb" ] && zip -j $ddir/$CAMNAME.zip -xi $rdir/$CAM_F/Distribution/$SMARGONAME;
if [ "$BUILD_LOG" = "on" ] ; then
zip -j $ddir/$CAMNAME.zip -xi $rdir/$CAM_F/Distribution/build.log
rm -rf $rdir/$CAM_F/Distribution/build.log;
fi
cd $rdir
apkdir="storage/OSEbuild/installation";
if [ "$N_PCSC" = "-pcsc" ] && [ "$CCID_ANDROID" = "on" ] && [ -e $ddir/application/pcsc.apk ] ; then
mkdir -p $apkdir
zip -j $apkdir/pcscd-${ABI}.zip -xi $PREFIX/sbin/pcscd
zip -j $apkdir/libccid-${ABI}.zip -xi $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux/libccid.so
zip -j $apkdir/libccidtwin-${ABI}.zip -xi $PREFIX/drivers/serial/libccidtwin.so
zip -j $apkdir/Info.plist.zip -xi $PREFIX/drivers/ifd-ccid.bundle/Contents/Info.plist
zip -j $apkdir/libpcsclite-${ABI}.zip -xi $PREFIX/lib/libpcsclite.so
zip -j $apkdir/libpcscspy-${ABI}.zip -xi $PREFIX/lib/libpcscspy.so
zip -j $apkdir/libusb-${ABI}.zip -xi $PREFIX/lib/libusb-1.0.so.0
zip -r $ddir/$CAMNAME.zip -xi $apkdir;
zip -j $ddir/$CAMNAME.zip -xi $ddir/application/pcsc.apk;
rm -rf $rdir/storage;
fi
if [ -e $ddir/application/cam.apk ] ; then
mkdir -p $apkdir
cp $rdir/$CAM_F/Distribution/$CAMNAME $apkdir/oscam
zip -j $apkdir/oscam-${ABI}.zip -xi $apkdir/oscam
rm -rf $apkdir/oscam
zip -r $ddir/$CAMNAME.zip -xi $apkdir;
zip -j $ddir/$CAMNAME.zip -xi $ddir/application/cam.apk;
rm -rf $rdir/storage;
fi
}
####
OSCAM_EMU() {
SVN_EMU="https://github.com/oscam-emu/oscam-emu/trunk"
SVN_SOURCE="http://www.streamboard.tv/svn/oscam/trunk"
REV_EMU=$(svn info $SVN_EMU | grep Revision | cut -d ' ' -f 2)
REV=$REV_EMU
SVN_MIN="67";
CAM_F="OSCam_Emu";
NP="-emu";
[ -e $rdir/emu ] && FILE_REV=$(svn info $rdir/emu | grep Revision | cut -d ' ' -f 2);
rev
}
####
OSCAM_MODERN() {
SVN_SOURCE="http://www.streamboard.tv/svn/oscam-addons/modern"
REV_EMU=$(svn info $SVN_SOURCE | grep Revision | cut -d ' ' -f 2)
REV=$REV_EMU
SVN_MIN="180";
CAM_F="OSCam_Modern";
NP="-modern";
[ -e $rdir/$CAM_F ] && FILE_REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2);
rev
}
####
OSCAM() {
SVN_SOURCE="http://www.streamboard.tv/svn/oscam/trunk"
REV_EMU=$(svn info $SVN_SOURCE | grep Revision | cut -d ' ' -f 2)
REV=$REV_EMU
SVN_MIN="10";
CAM_F="OSCam";
NP="";
[ -e $rdir/$CAM_F ] && FILE_REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2);
rev
}
####
rev() {
if [ ! -e $rdir/$CAM_F ] ; then
REV=$(dialog --no-cancel --title "Online SVN:$REV_EMU ($SVN_MIN to $REV_EMU)" --inputbox "$REV" 8 30 "$REV_EMU" 3>&1 1>&2 2>&3)
else
dialog --title "$CAM_F UPDATE" --backtitle "" --yesno "Online SVN ('$REV_EMU') = Local SVN ('$FILE_REV')" 7 60
response=$?
case $response in
   0) 
REV=$(dialog  --no-cancel --title "Local svn:$FILE_REV  ($SVN_MIN to $REV_EMU)" --inputbox "$REV" 8 30 "$REV_EMU" 3>&1 1>&2 2>&3)
;;
   1) menu_android;;
   255) echo "[ESC] key pressed.";;
esac
fi
if [ "$REV" -ge $SVN_MIN ] && [ "$REV" -le "$REV_EMU" ] ; then
null="null"
else
rev
fi
if [ -e $rdir/$CAM_F ] ; then
rm -rf $rdir/$CAM_F
fi
if [ "$CAM_F" = "OSCam_Emu" ] ; then
cd $rdir
svn co -r $REV $SVN_EMU emu | $progressbox
if [ 225 -le "$REV" ] ; then
REV=$(grep -a " Makefile" emu/oscam-emu.patch | grep -a "revision" | cut -c24-28)
else
REV=$(grep -a " Makefile" emu/oscam-emu.patch | grep -a "revision" | cut -c24-27)
fi
cd $rdir
svn co -r $REV $SVN_SOURCE $CAM_F | $progressbox
else
cd $rdir
svn co -r $REV $SVN_SOURCE $CAM_F | $progressbox
REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2)
fi
FILE_REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2)
cd $rdir/$CAM_F
[ "$CAM_F" = "OSCam_Emu" ] && patch -p0 < ../emu/oscam-emu.patch | $progressbox;
if [ -e $ddir/application/liboscam_stapi5.a ] ; then
mkdir $rdir/$CAM_F/stapi 
cp $ddir/application/liboscam_stapi5.a -xi $rdir/$CAM_F/stapi
fi
######
menu_android
######
}
#################################################
ANDROID_NDK() {
if [ "$ANDROID_NDK_AU_DOWNLOAD" = "on" ] ; then
ANDROID_NDK_ROOT="$btdir/android-ndk-${ANDROID_NDK_REV}";
if [ ! -e $tcdir ] ; then
if [ ! -e ${ANDROID_NDK_ROOT} ] ; then
[ ! -e "$rdir/toolchains" ] && mkdir -p $rdir/toolchains;
[ ! -e $btdir ] && mkdir -p $btdir;
cd $btdir
#wget -c --progress=bar:force "http://dl.google.com/android/ndk/android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin" 6 50
#chmod a+x android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin
#./android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin 2>&1 | $progressbox
wget -c --progress=bar:force "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip" 6 50
if [ ! -e $btdir/android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip'' 7 60
clear && exit;
fi
unzip android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip | $progressbox
[ "$BACKUP" = "off" ]  && rm android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin;
fi
fi
else
if [ ! -e ${ANDROID_NDK_ROOT} ] ; then
ANDROID_NDK_ROOT=$(dialog --no-cancel --inputbox "ANDROID_NDK_ROOT?" 8 78 $ANDROID_NDK_ROOT 3>&1 1>&2 2>&3)
ANDROID_NDK
fi
if [ ! -e ${ANDROID_NDK_ROOT} ] ; then
ANDROID_NDK
fi
fi
if [ ! -e $tcdir ] ; then
$ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh --arch=$ARCH --install-dir=$tcdir --platform=android-${ANDROID_API_LEVEL} --toolchain=${Toolchain}-${TOOLCHAIN_VERSION} 2>&1 | $progressbox 
cd $tcdir
##OSCam TommyDS patch
if [ ! -e stdint.h.patch ] && [ "$ANDROID_API_LEVEL" -lt "21" ] ; then
echo '@@ -259,4 +259,10 @@' >> stdint.h.patch
echo ' /* Keep the kernel from trying to define these types... */' >> stdint.h.patch
echo ' #define __BIT_TYPES_DEFINED__' >> stdint.h.patch
echo '' >> stdint.h.patch
echo '+#if defined(__LP64__)' >> stdint.h.patch
echo '+#  define SIZE_MAX       UINT64_MAX' >> stdint.h.patch
echo '+#else' >> stdint.h.patch
echo '+#  define SIZE_MAX       UINT32_MAX' >> stdint.h.patch
echo '+#endif' >> stdint.h.patch
echo '+' >> stdint.h.patch
echo ' #endif /* _STDINT_H */' >> stdint.h.patch
patch -p1 < stdint.h.patch  sysroot/usr/include/stdint.h
fi
fi
if [ ! -e $tcdir ] ; then
dialog --title "ERROR!" --msgbox '                 ANDROID BUILD ERROR! \n \n ARCH='$ARCH' \n TOOLCHAIN_VERSION='$TOOLCHAIN_VERSION' \n ANDROID_API_LEVEL='$ANDROID_API_LEVEL'' 9 60
clear && exit;
fi
###############################
export PATH=$tcdir/bin:$PATH
#export SYSROOT=$tcdir/$Toolchain/sysroot
CROSS=$tcdir/bin/${PLATFORM}-
PREFIX=$tcdir/sysroot/usr
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
###############################
OPENSSL
LIBUSB
if [ "$PCSC_ANDROID" = "on" ] ; then
PCSCLITE
if [ "$CCID_ANDROID" = "on" ] ; then
CCID
fi
fi
}
####
OSSL(){
echo "---------------------------------------------------------";
echo "BUILD openssl-${OPENSSL_VERSION}: (5-10 minutes)";
echo "---------------------------------------------------------";
sleep 5
}
OPENSSL(){
if [ ! -e $PKG_CONFIG_PATH/openssl.pc ] ; then
OSSL | $progressbox
cd $btdir
if [ ! -e $btdir/openssl-${OPENSSL_VERSION}.tar.gz ] ; then
wget -c --progress=bar:force "http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "openssl-${OPENSSL_VERSION}.tar.gz" 6 50
if [ ! -e $btdir/openssl-${OPENSSL_VERSION}.tar.gz ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz'' 7 60
clear && exit;
fi
fi
tar -xvf $btdir/openssl-${OPENSSL_VERSION}.tar.gz
cd $btdir/openssl-${OPENSSL_VERSION}
ossl_="-UOPENSSL_BN_ASM_PART_WORDS";
CC=${CROSS}gcc LD=${CROSS}ld AR=${CROSS}ar STRIP=${CROSS}strip RANLIB=${CROSS}ranlib ./Configure shared no-asm no-krb5 no-gost zlib-dynamic --openssldir=${PREFIX} linux-generic${L_1}
mv "Makefile" "Makefile~"
sed "s/\.so\.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)/\.so/" Makefile~ > Makefile~1
sed "s/\$(SHLIB_MAJOR).\$(SHLIB_MINOR)//" Makefile~1 > Makefile
make CC=${CROSS}gcc LD=${CROSS}ld AR=${CROSS}ar STRIP=${CROSS}strip RANLIB=${CROSS}ranlib CFLAGS="${CFLAGS} ${ossl_}" SHARED_LDFLAGS="${LDFLAGS}"
make install
rm -rf $btdir/openssl-${OPENSSL_VERSION};
[ "$BACKUP" = "off" ]  && rm -rf $btdir/openssl-${OPENSSL_VERSION}.tar.gz;
if [ ! -e $PKG_CONFIG_PATH/openssl.pc ] ; then
dialog --title "EXIT" --yesno "BUILD ERROR: openssl-${OPENSSL_VERSION}" 5 60
case $? in
   0) clear && exit ;;
esac
fi
fi
}
LUSB(){
echo "---------------------------------------------------------";
echo "BUILD libusb-${LIBUSB_VERSION}: (2-5 minutes)"
echo "---------------------------------------------------------";
sleep 5
}
LIBUSB(){
if [ ! -e $PKG_CONFIG_PATH/libusb-1.0.pc ] ; then
LUSB | $progressbox
cd $btdir
if [ ! -e $btdir/libusb-${LIBUSB_VERSION}.tar.bz2 ] ; then
wget -c --progress=bar:force "https://github.com/libusb/libusb/releases/download/v${LIBUSB_VERSION}/libusb-${LIBUSB_VERSION}.tar.bz2" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "libusb-${LIBUSB_VERSION}.tar.bz2" 6 50
if [ ! -e $btdir/libusb-${LIBUSB_VERSION}.tar.bz2 ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'https://github.com/libusb/libusb/releases/download/v${LIBUSB_VERSION}/libusb-${LIBUSB_VERSION}.tar.bz2'' 7 60
clear && exit;
fi
fi
tar -jxf $btdir/libusb-${LIBUSB_VERSION}.tar.bz2
cd $btdir/libusb-${LIBUSB_VERSION}
./configure CC=${CROSS}gcc LD=${CROSS}ld AR=${CROSS}ar STRIP=${CROSS}strip RANLIB=${CROSS}ranlib CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" --host=${PLATFORM} --prefix=${PREFIX} --enable-static --enable-shared --disable-udev
make
make install
rm -rf $btdir/libusb-${LIBUSB_VERSION};
[ "$BACKUP" = "off" ]  && rm -rf $btdir/libusb-${LIBUSB_VERSION}.tar.bz2;
if [ ! -e $PKG_CONFIG_PATH/libusb-1.0.pc ] ; then
dialog --title "EXIT" --yesno "BUILD ERROR: libusb-${LIBUSB_VERSION}" 5 60
case $? in
   0) clear && exit ;;
esac
fi
fi
}
PCSCL(){
echo "---------------------------------------------------------";
echo "BUILD pcsc-lite-${PCSC_LITE_VERSION}: (2-5 minutes)"
echo "---------------------------------------------------------";
sleep 5
}
PCSCLITE(){
if [ ! -e $PKG_CONFIG_PATH/libpcsclite.pc ] ; then
PCSCL | $progressbox
cd $btdir
if [ ! -e $btdir/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2 ] ; then
wget -c --progress=bar:force "https://alioth.debian.org/frs/download.php/file/4225/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2" 6 50
if [ ! -e $btdir/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2 ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'https://alioth.debian.org/frs/download.php/file/4203/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2'' 7 60
clear && exit;
fi
fi
tar -jxf $btdir/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2
cd $btdir/pcsc-lite-${PCSC_LITE_VERSION}
##diff -Naur sd-daemon.c sd-daemon.c.patch
if [ ! -e sd-daemon.c.patch ] ; then
echo '@@ -32,7 +32,7 @@' >> sd-daemon.c.patch
echo ' #include <sys/stat.h>' >> sd-daemon.c.patch
echo ' #include <sys/socket.h>' >> sd-daemon.c.patch
echo ' #include <sys/un.h>' >> sd-daemon.c.patch
echo '-#include <sys/fcntl.h>' >> sd-daemon.c.patch
echo '+#include <fcntl.h>' >> sd-daemon.c.patch
echo ' #include <netinet/in.h>' >> sd-daemon.c.patch
echo ' #include <stdlib.h>' >> sd-daemon.c.patch
echo ' #include <errno.h>' >> sd-daemon.c.patch
echo '@@ -44,7 +44,7 @@' >> sd-daemon.c.patch
echo ' #include <limits.h>' >> sd-daemon.c.patch
echo ' ' >> sd-daemon.c.patch
echo ' #if defined(__linux__)' >> sd-daemon.c.patch
echo '-#include <mqueue.h>' >> sd-daemon.c.patch
echo '+//#include <mqueue.h>' >> sd-daemon.c.patch
echo ' #endif' >> sd-daemon.c.patch
echo ' ' >> sd-daemon.c.patch
echo ' #include "sd-daemon.h"' >> sd-daemon.c.patch
echo '@@ -377,7 +377,7 @@' >> sd-daemon.c.patch
echo ' ' >> sd-daemon.c.patch
echo '         return 1;' >> sd-daemon.c.patch
echo ' }' >> sd-daemon.c.patch
echo '-' >> sd-daemon.c.patch
echo '+/*' >> sd-daemon.c.patch
echo ' _sd_export_ int sd_is_mq(int fd, const char *path) {' >> sd-daemon.c.patch
echo ' #if !defined(__linux__)' >> sd-daemon.c.patch
echo '         return 0;' >> sd-daemon.c.patch
echo '@@ -414,7 +414,7 @@' >> sd-daemon.c.patch
echo '         return 1;' >> sd-daemon.c.patch
echo ' #endif' >> sd-daemon.c.patch
echo ' }' >> sd-daemon.c.patch
echo '-' >> sd-daemon.c.patch
echo '+*/' >> sd-daemon.c.patch
echo ' _sd_export_ int sd_notify(int unset_environment, const char *state) {' >> sd-daemon.c.patch
echo ' #if defined(DISABLE_SYSTEMD) || !defined(__linux__) || !defined(SOCK_CLOEXEC)' >> sd-daemon.c.patch
echo '         return 0;' >> sd-daemon.c.patch
patch -p1 < sd-daemon.c.patch  src/sd-daemon.c
fi
./configure CC=${CROSS}gcc LD=${CROSS}ld AR=${CROSS}ar STRIP=${CROSS}strip RANLIB=${CROSS}ranlib CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" --disable-libudev --host=${PLATFORM} --prefix=${PREFIX} --exec-prefix=${PREFIX} --enable-static --enable-serial --enable-shared --enable-usb --enable-libusb --enable-usbdropdir="$PCSC_APP_DIR/drivers" --enable-ipcdir="/dev" --enable-confdir="$PCSC_APP_DIR/reader.conf.d"
make
make install
rm -rf $btdir/pcsc-lite-${PCSC_LITE_VERSION};
[ "$BACKUP" = "off" ]  && rm -rf $btdir/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2;
if [ ! -e $PKG_CONFIG_PATH/libpcsclite.pc ] ; then
dialog --title "EXIT" --yesno "BUILD ERROR: pcsc-lite-${PCSC_LITE_VERSION}" 5 60
case $? in
   0) clear && exit ;;
esac
fi
fi
}
CCI(){
echo "---------------------------------------------------------";
echo "BUILD ccid-${CCID_VERSION}: (2-5 minutes)"
echo "---------------------------------------------------------";
sleep 5
}
CCID(){
if [ ! -e $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux/libccid.so ] ; then
CCI | $progressbox
cd $btdir
if [ ! -e $btdir/ccid-${CCID_VERSION}.tar.bz2 ] ; then
wget -c --progress=bar:force "https://alioth.debian.org/frs/download.php/file/4230/ccid-${CCID_VERSION}.tar.bz2" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "ccid-${CCID_VERSION}.tar.bz2" 6 50
if [ ! -e $btdir/ccid-${CCID_VERSION}.tar.bz2 ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'https://alioth.debian.org/frs/download.php/file/4205/ccid-${CCID_VERSION}.tar.bz2'' 7 60
clear && exit;
fi
fi
tar -jxf $btdir/ccid-${CCID_VERSION}.tar.bz2
cd $btdir/ccid-${CCID_VERSION}
./configure CC=${CROSS}gcc LD=${CROSS}ld AR=${CROSS}ar STRIP=${CROSS}strip RANLIB=${CROSS}ranlib CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" --host=${PLATFORM} --prefix=${PREFIX} --exec-prefix=${PREFIX} --enable-twinserial --enable-serialconfdir="$PCSC_APP_DIR/reader.conf.d" --enable-static --enable-shared
make
make install
cd $rdir
[ ! -e $PREFIX/reader.conf.d ] && mkdir -p $PREFIX/reader.conf.d;
[ ! -e $PREFIX/drivers/serial ] && mkdir -p $PREFIX/drivers/serial;
[ ! -e $PREFIX/etc/udev/rules.d ] && mkdir -p $PREFIX/etc/udev/rules.d;
[ ! -e $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux ] && mkdir -p $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux
cp $btdir/ccid-${CCID_VERSION}/src/92_pcscd_ccid.rules $PREFIX/etc/udev/rules.d/92_pcscd_ccid.rules
cp $btdir/ccid-${CCID_VERSION}/src/Info.plist $PREFIX/drivers/ifd-ccid.bundle/Contents/Info.plist
cp $btdir/ccid-${CCID_VERSION}/src/.libs/libccid.so $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux/libccid.so
cp $btdir/ccid-${CCID_VERSION}/src/.libs/libccidtwin.so $PREFIX/drivers/serial/libccidtwin.so
if [ ! -e $PREFIX/reader.conf.d/libccidtwin ] ; then
cp $btdir/ccid-${CCID_VERSION}/src/reader.conf.in $PREFIX/reader.conf.d/libccidtwin
echo "#LIBPATH          $PCSC_APP_DIR/drivers/serial/libccidtwin.so" >> $PREFIX/reader.conf.d/libccidtwin
fi
rm -rf $btdir/ccid-${CCID_VERSION};
[ "$BACKUP" = "off" ]  && rm -rf $btdir/ccid-${CCID_VERSION}.tar.bz2;
if [ ! -e $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux/libccid.so ] ; then
dialog --title "EXIT" --yesno "BUILD ERROR: ccid-${CCID_VERSION}" 5 60
case $? in
   0) clear && exit ;;
esac
fi
fi
}
#################################
menu(){
selected=$(dialog --stdout --clear --colors --backtitle $0 --title "" --menu "" 9 60 8 \
	1	"Oscam" \
	2	"Oscam-emu" \
	3	"Oscam-modern");
case $selected in
	1) OSCAM ;;
	2) OSCAM_EMU ;;
	3) OSCAM_MODERN ;;
	esac
clear && exit;
}
####
menu_android(){
cmd=(dialog --separate-output --no-cancel --checklist "$CAM_F-Rev:$FILE_REV" 16 60 10)
options=(arm "arm-linux-androideabi" off
	 armeabi "armv5" off
	 armeabi-v7a "armv7-a" off
	 armeabi-v7a_neon "armv7-a_neon" off
	 x86 "i686-linux-android" off
	 mips "mipsel-linux-android" off
	 arm64 "aarch64-linux-android" off
	 x86_64 "x86_64-linux-android" off
	 mips64 "mips64el-linux-android" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
for choice in $choices
do
    case $choice in
    	arm)
	ARCH="arm";
	L_1="32";
	CFLAGS="-Os"
	LDFLAGS=" "
	ABI="armeabi";
	android
	;;
	armeabi)
	ARCH="arm";
	L_1="32";
	CFLAGS="-Os -march=armv5te -mtune=xscale -msoft-float"
	LDFLAGS="-Wl,--exclude-libs,libunwind.a "
	ABI="armeabi";
	android
	;;
	armeabi-v7a)
	ARCH="arm";
	L_1="32";
	CFLAGS="-Os -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
	LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
	ABI="armeabi-v7a";
	android
	;;
	armeabi-v7a_neon)
	ARCH="arm";
	L_1="32";
	CFLAGS="-Os -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mfpu=neon"
	LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
	ABI="armeabi-v7a";
	android
	;;
	x86)
	ARCH="x86";
	L_1="32";
	CFLAGS="-O2"
	LDFLAGS=""
	ABI="x86";
	android
	;;
	mips)
	ARCH="mips";
	L_1="32";
	CFLAGS="-O2 -mips32"
	LDFLAGS=""
	ABI="mips";
	android
	;;
	arm64)
	ARCH="arm64";
	L_1="64";
	CFLAGS="-O2"
	LDFLAGS=""
	[ "$ANDROID_API_LEVEL" -lt "21" ] && ANDROID_API_LEVEL="21"
	ABI="arm64-v8a";
	android
	;;
	x86_64)
	ARCH="x86_64";
	L_1="64";
	CFLAGS="-O2"
	LDFLAGS=""
	[ "$ANDROID_API_LEVEL" -lt "21" ] && ANDROID_API_LEVEL="21"
	ABI="x86_64";
	android
	;;
	mips64)
	ARCH="mips64";
	L_1="64";
	CFLAGS="-O2"
	LDFLAGS=""
	[ "$ANDROID_API_LEVEL" -lt "21" ] && ANDROID_API_LEVEL="21"
	ABI="mips64";
	android
	;;
	esac
	done
clear && exit;
}
#######################
case $1 in
h|-h|--h|help|-help|--help|Help|HELP)
MACHINE=`uname -o`
case "$MACHINE" in
GNU/Linux*)
echo "-----------------------------"
echo "Build:     "
echo "	Oscam";
echo "	Oscam-emu"
echo "	Oscam-modern";
echo "-----------------------------"
echo "PLATFORM:";
echo "	ANDROID:arm,x86,mips,arm64,x86_64,mips64";
echo "-----------------------------"
echo "Packages required:"
echo "		dialog subversion gcc make zip"
echo "-----------------------------"
echo "   $0"
echo "-----------------------------"
;;
*)
echo "this is not linux operating system";
;;
esac
exit 0;
;;
esac
#######################
menu
#######################
exit 0;

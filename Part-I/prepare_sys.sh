#!/bin/bash

TXT_RED="\033[1;31m"
TXT_GREEN="\033[1;32m"
TXT_YELLOW="\033[1;33m"
TXT_BLUE="\033[1;34m"
FANCY_RESET="\033[0m"

print_color () {
    echo -e "$1$2$FANCY_RESET"
}

user=$(whoami)

if [ $user != "root" ]; then 
    echo -e "Please, Load this script with root\n"
    exit 1
fi

handle_error() {
    print_color "$TXT_RED" "Error: line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR


create_md5sum () {
cat << EOF >> ./md5sum
590765dee95907dbc3c856f7255bd669  acl-2.3.2.tar.xz
227043ec2f6ca03c0948df5517f9c927  attr-2.5.2.tar.gz
1be79f7106ab6767f18391c5e22be701  autoconf-2.72.tar.xz
4017e96f89fca45ca946f1c5db6be714  automake-1.16.5.tar.xz
ad5b38410e3bf0e9bcc20e2765f5e3f9  bash-5.2.21.tar.gz
e249b1f86f886d6fb71c15f72b65dd3d  bc-6.7.5.tar.xz
a075178a9646551379bfb64040487715  binutils-2.42.tar.xz
c28f119f405a2304ff0a7ccdcc629713  bison-3.8.2.tar.xz
67e051268d0c475ea773822f7500d0e5  bzip2-1.0.8.tar.gz
50fcafcecde5a380415b12e9c574e0b2  check-0.15.2.tar.gz
459e9546074db2834eefe5421f250025  coreutils-9.4.tar.xz
46070a3487817ff690981f8cd2ba9376  dbus-1.14.10.tar.xz
68c5208c58236eba447d7d6d1326b821  dejagnu-1.6.3.tar.gz
2745c50f6f4e395e7b7d52f902d075bf  diffutils-3.10.tar.xz
6b4f18a33873623041857b4963641ee9  e2fsprogs-1.47.0.tar.gz
79ad698e61a052bea79e77df6a08bc4b  elfutils-0.190.tar.bz2
bd169cb11f4b9bdfddadf9e88a5c4d4b  expat-2.6.0.tar.xz
00fce8de158422f5ccd2666512329bd2  expect5.45.4.tar.gz
26b2a96d4e3a8938827a1e572afd527a  file-5.45.tar.gz
4a4a547e888a944b2f3af31d789a1137  findutils-4.9.0.tar.xz
2882e3179748cc9f9c23ec593d6adc8d  flex-2.6.4.tar.gz
3bc52f1952b9a78361114147da63c35b  flit_core-3.9.0.tar.gz
97c5a7d83f91a7e1b2035ebbe6ac7abd  gawk-5.3.0.tar.xz
e0e48554cc6e4f261d55ddee9ab69075  gcc-13.2.0.tar.xz
8551961e36bf8c70b7500d255d3658ec  gdbm-1.23.tar.gz
2d8507d003ef3ddd1c172707ffa97ed8  gettext-0.22.4.tar.xz
be81e87f72b5ea2c0ffe2bedfeb680c6  glibc-2.39.tar.xz
956dc04e864001a9c22429f761f2c283  gmp-6.3.0.tar.xz
9e251c0a618ad0824b51117d5d9db87e  gperf-3.1.tar.gz
7c9bbd74492131245f7cdb291fa142c0  grep-3.11.tar.xz
5e4f40315a22bb8a158748e7d5094c7d  groff-1.23.0.tar.gz
60c564b1bdc39d8e43b3aab4bc0fb140  grub-2.12.tar.xz
d5c9fc9441288817a4a0be2da0249e29  gzip-1.13.tar.xz
aed66d04de615d76c70890233081e584  iana-etc-20240125.tar.gz
9e5a6dfd2d794dc056a770e8ad4a9263  inetutils-2.5.tar.xz
12e517cac2b57a0121cda351570f1e63  intltool-0.51.0.tar.gz
35d8277d1469596b7edc07a51470a033  iproute2-6.7.0.tar.xz
caf5418c851eac59e70a78d9730d4cea  Jinja2-3.1.3.tar.gz
e2fd7adccf6b1e98eb1ae8d5a1ce5762  kbd-2.6.4.tar.xz
6165867e1836d51795a11ea4762ff66a  kmod-31.tar.xz
cf05e2546a3729492b944b4874dd43dd  less-643.tar.gz
4667bacb837f9ac4adb4a1a0266f4b65  libcap-2.69.tar.xz
0da1a5ed7786ac12dcbaf0d499d8a049  libffi-3.4.4.tar.gz
1a48b5771b9f6c790fb4efdb1ac71342  libpipeline-1.5.7.tar.gz
2fc0b6ddcd66a89ed6e45db28fa44232  libtool-2.4.7.tar.xz
b84cd4104e08c975063ec6c4d0372446  libxcrypt-4.4.36.tar.xz
370e1b6155ae63133380e421146619e0  linux-6.7.4.tar.xz
0d90823e1426f1da2fd872df0311298d  m4-1.4.19.tar.xz
c8469a3713cbbe04d955d4ae4be23eeb  make-4.4.1.tar.gz
67e0052fa200901b314fad7b68c9db27  man-db-2.12.0.tar.xz
26b39e38248144156d437e1e10cb20bf  man-pages-6.06.tar.xz
8fe7227653f2fb9b1ffe7f9f2058998a  MarkupSafe-2.1.5.tar.gz
2d0ebd3a24249617b1c4d30026380cf8  meson-1.3.2.tar.gz
5c9bc658c9fd0f940e8e3e0f09530c62  mpc-1.3.1.tar.gz
523c50c6318dde6f9dc523bc0244690a  mpfr-4.2.1.tar.xz
c5367e829b6d9f3f97b280bb3e6bfbc3  ncurses-6.4-20230520.tar.xz
32151c08211d7ca3c1d832064f6939b0  ninja-1.11.1.tar.gz
c239213887804ba00654884918b37441  openssl-3.2.1.tar.gz
78ad9937e4caadcba1526ef1853730d5  patch-2.7.6.tar.xz
d3957d75042918a23ec0abac4a2b7e0a  perl-5.38.2.tar.xz
bc29d74c2483197deb9f1f3b414b7918  pkgconf-2.1.1.tar.xz
2f747fc7df8ccf402d03e375c565cf96  procps-ng-4.0.4.tar.xz
ed3206da1184ce9e82d607dc56c52633  psmisc-23.6.tar.xz
e7c178b97bf8f7ccd677b94d614f7b3c  Python-3.12.2.tar.xz
8a6310f6288e7f60c3565277ec3b5279  python-3.12.2-docs-html.tar.bz2
4aa1b31be779e6b84f9a96cb66bc50f6  readline-8.2.tar.gz
6aac9b2dbafcd5b7a67a8a9bcb8036c3  sed-4.9.tar.xz
6f6eb780ce12c90d81ce243747ed7ab0  setuptools-69.1.0.tar.gz
452b0e59f08bf618482228ba3732d0ae  shadow-4.14.5.tar.xz
521cda27409a9edf0370c128fae3e690  systemd-255.tar.gz
1ebe54d7a80f9abf8f2d14ddfeb2432d  systemd-man-pages-255.tar.xz
a2d8042658cfd8ea939e6d911eaf4152  tar-1.35.tar.xz
0e4358aade2f5db8a8b6f2f6d9481ec2  tcl8.6.13-src.tar.gz
4452f2f6d557f5598cca17b786d6eb68  tcl8.6.13-html.tar.gz
edd9928b4a3f82674bcc3551616eef3b  texinfo-7.1.tar.xz
2349edd8335245525cc082f2755d5bf4  tzdata2024a.tar.gz
f3591e6970c017bb4bcd24ae762a98f5  util-linux-2.39.3.tar.xz
79dfe62be5d347b1325cbd5ce2a1f9b3  vim-9.1.0041.tar.gz
802ad6e5f9336fcb1c76b7593f0cd22d  wheel-0.42.0.tar.gz
89a8e82cfd2ad948b349c0a69c494463  XML-Parser-2.47.tar.gz
7ade7bd1181a731328f875bec62a9377  xz-5.4.6.tar.xz
9855b6d802d7fe5b7bd5b196a2271655  zlib-1.3.1.tar.gz
63251602329a106220e0a5ad26ba656f  zstd-1.5.5.tar.gz
2d1691a629c558e894dbb78ee6bf34ef  bash-5.2.21-upstream_fixes-1.patch
6a5ac7e89b791aae556de0f745916f7f  bzip2-1.0.8-install_docs-1.patch
cca7dc8c73147444e77bc45d210229bb  coreutils-9.4-i18n-1.patch
9a5997c3452909b1769918c759eff8a2  glibc-2.39-fhs-1.patch
f75cca16a38da6caa7d52151f7136895  kbd-2.6.4-backspace-1.patch
9ed497b6cb8adcb8dbda9dee9ebce791  readline-8.2-upstream_fixes-3.patch
8d9c1014445c463cf7c24c162b1e0686  systemd-255-upstream_fixes-1.patch
EOF
}


create_package_list () {
cat << EOF >> ./wget-list-systemd
https://download.savannah.gnu.org/releases/acl/acl-2.3.2.tar.xz
https://download.savannah.gnu.org/releases/attr/attr-2.5.2.tar.gz
https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz
https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz
https://ftp.gnu.org/gnu/bash/bash-5.2.21.tar.gz
https://github.com/gavinhoward/bc/releases/download/6.7.5/bc-6.7.5.tar.xz
https://sourceware.org/pub/binutils/releases/binutils-2.42.tar.xz
https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz
https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
https://github.com/libcheck/check/releases/download/0.15.2/check-0.15.2.tar.gz
https://ftp.gnu.org/gnu/coreutils/coreutils-9.4.tar.xz
https://dbus.freedesktop.org/releases/dbus/dbus-1.14.10.tar.xz
https://ftp.gnu.org/gnu/dejagnu/dejagnu-1.6.3.tar.gz
https://ftp.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz
https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.47.0/e2fsprogs-1.47.0.tar.gz
https://sourceware.org/ftp/elfutils/0.190/elfutils-0.190.tar.bz2
https://toolchains.bootlin.com/downloads/releases/sources/expat-2.6.0/expat-2.6.0.tar.xz
https://prdownloads.sourceforge.net/expect/expect5.45.4.tar.gz
https://astron.com/pub/file/file-5.45.tar.gz
https://ftp.gnu.org/gnu/findutils/findutils-4.9.0.tar.xz
https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
https://pypi.org/packages/source/f/flit-core/flit_core-3.9.0.tar.gz
https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz
https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
https://ftp.gnu.org/gnu/gdbm/gdbm-1.23.tar.gz
https://ftp.gnu.org/gnu/gettext/gettext-0.22.4.tar.xz
https://ftp.gnu.org/gnu/glibc/glibc-2.39.tar.xz
https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
https://ftp.gnu.org/gnu/gperf/gperf-3.1.tar.gz
https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz
https://ftp.gnu.org/gnu/groff/groff-1.23.0.tar.gz
https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz
https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz
https://github.com/Mic92/iana-etc/releases/download/20240125/iana-etc-20240125.tar.gz
https://ftp.gnu.org/gnu/inetutils/inetutils-2.5.tar.xz
https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz
https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.7.0.tar.xz
https://pypi.org/packages/source/J/Jinja2/Jinja2-3.1.3.tar.gz
https://www.kernel.org/pub/linux/utils/kbd/kbd-2.6.4.tar.xz
https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-31.tar.xz
https://www.greenwoodsoftware.com/less/less-643.tar.gz
https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.69.tar.xz
https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz
https://download.savannah.gnu.org/releases/libpipeline/libpipeline-1.5.7.tar.gz
https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz
https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz
https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.7.4.tar.xz
https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz
https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz
https://download.savannah.gnu.org/releases/man-db/man-db-2.12.0.tar.xz
https://www.kernel.org/pub/linux/docs/man-pages/man-pages-6.06.tar.xz
https://pypi.org/packages/source/M/MarkupSafe/MarkupSafe-2.1.5.tar.gz
https://github.com/mesonbuild/meson/releases/download/1.3.2/meson-1.3.2.tar.gz
https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz
https://anduin.linuxfromscratch.org/LFS/ncurses-6.4-20230520.tar.xz
https://github.com/ninja-build/ninja/archive/v1.11.1/ninja-1.11.1.tar.gz
https://www.openssl.org/source/openssl-3.2.1.tar.gz
https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz
https://www.cpan.org/src/5.0/perl-5.38.2.tar.xz
https://distfiles.ariadne.space/pkgconf/pkgconf-2.1.1.tar.xz
https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-4.0.4.tar.xz
https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-23.6.tar.xz
https://www.python.org/ftp/python/3.12.2/Python-3.12.2.tar.xz
https://www.python.org/ftp/python/doc/3.12.2/python-3.12.2-docs-html.tar.bz2
https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz
https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz
https://pypi.org/packages/source/s/setuptools/setuptools-69.1.0.tar.gz
https://github.com/shadow-maint/shadow/releases/download/4.14.5/shadow-4.14.5.tar.xz
https://github.com/systemd/systemd/archive/v255/systemd-255.tar.gz
https://anduin.linuxfromscratch.org/LFS/systemd-man-pages-255.tar.xz
https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz
https://downloads.sourceforge.net/tcl/tcl8.6.13-src.tar.gz
https://downloads.sourceforge.net/tcl/tcl8.6.13-html.tar.gz
https://ftp.gnu.org/gnu/texinfo/texinfo-7.1.tar.xz
https://www.iana.org/time-zones/repository/releases/tzdata2024a.tar.gz
https://www.kernel.org/pub/linux/utils/util-linux/v2.39/util-linux-2.39.3.tar.xz
https://github.com/vim/vim/archive/v9.1.0041/vim-9.1.0041.tar.gz
https://pypi.org/packages/source/w/wheel/wheel-0.42.0.tar.gz
https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.47.tar.gz
https://github.com/tukaani-project/xz/releases/download/v5.4.6/xz-5.4.6.tar.xz
https://zlib.net/fossils/zlib-1.3.1.tar.gz
https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-1.5.5.tar.gz
https://www.linuxfromscratch.org/patches/lfs/12.1/bash-5.2.21-upstream_fixes-1.patch
https://www.linuxfromscratch.org/patches/lfs/12.1/bzip2-1.0.8-install_docs-1.patch
https://www.linuxfromscratch.org/patches/lfs/12.1/coreutils-9.4-i18n-1.patch
https://www.linuxfromscratch.org/patches/lfs/12.1/glibc-2.39-fhs-1.patch
https://www.linuxfromscratch.org/patches/lfs/12.1/kbd-2.6.4-backspace-1.patch
https://www.linuxfromscratch.org/patches/lfs/12.1/readline-8.2-upstream_fixes-3.patch
https://www.linuxfromscratch.org/patches/lfs/12.1/systemd-255-upstream_fixes-1.patch
EOF
}

# Create File Systems

set -eu
print_color "$TXT_BLUE" "Creating File System..."

mkfs -v -t ext4 /dev/loop0p1
mkfs -v -t ext4 /dev/loop0p2
mkswap    /dev/loop0p3

print_color "$TXT_GREEN" "File System Created"

# Mounting Partition
print_color "$TXT_BLUE" "Mounting Partition..."

echo "export LFS=/mnt/lfs" >> ~/.bash_profile
echo "export LFS=/mnt/lfs" >> ~/.bashrc
export LFS=/mnt/lfs
mkdir -pv $LFS
mount -v -t ext4 /dev/loop0p2 $LFS
swapon -v /dev/loop0p3

print_color "$TXT_GREEN" "Partition Mounted"
set +eu

# Download Packages
print_color "$TXT_BLUE" "Starting Download Package"

mkdir -pv $LFS/sources
chmod -v a+wt $LFS/sources

print_color "$TXT_BLUE" "Downloading Package..."

apt-get install wget -y
create_package_list
wget --input-file=./wget-list-systemd --continue --directory-prefix=$LFS/sources;
rm ./wget-list-systemd

print_color "$TXT_GREEN" "Packages Downloaded"


print_color "$TXT_YELLOW" "Starting to Check if every package is here, otherwise download missing package manually."
pushd $LFS/sources
  create_md5sum
  md5sum -c md5sum
  rm md5sum
popd

# Building folders
print_color "$TXT_BLUE" "Creating folders and setting up lfs user..."
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin} 

for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv $LFS/tools

# Create lfs User
if ! getent group lfs > /dev/null 2>&1; then
    echo "Creating group 'lfs'."
    groupadd lfs
else
    echo "Group 'lfs' already exists."
fi
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}

case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac

# set lfs user env

print_color "$TXT_BLUE" "Creating folders and Setting up lfs user environment ..."

cat > /home/lfs/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
cat > /home/lfs/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF
cat >> /home/lfs/.bashrc << "EOF"
export MAKEFLAGS=-j$(nproc)
EOF
cat >> ~/.bashrc << "EOF"
export MAKEFLAGS=-j$(nproc)
EOF
cp -f ../Part-II/install_cross_tools.sh /home/lfs/.

print_color "$TXT_GREEN" "Setup Complete. Follow the manual for further instructions."
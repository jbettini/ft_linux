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
78aae762c95e2d731faf88d482e4cde5  net-tools-2.10.tar.xz
f701ab57eb8e7d9c105b2cd5d809b29a  libtasn1-4.19.0.tar.gz
2610cef2951d83d7037577eaae1acb54  p11-kit-0.25.3.tar.xz
5e0acf9fbdde85181bddd510f4624841  nspr-4.35.tar.gz
743c99f996add46273694df83c9140d4  sqlite-autoconf-3450100.tar.gz
4502fcae1b32da310fffdfb3c67f6985  nss-3.98.tar.gz
04bd86fe2eb299788439c3466782ce45  make-ca-1.13.tar.xz
0dfba19989ae06b8e7a49a7cd18472a1  libunistring-1.1.tar.xz
de2818c7dea718a4f264f463f595596b  libidn2-2.3.7.tar.gz
870a798ee9860b6e77896548428dba7b  libpsl-0.21.5.tar.gz
a8e9ab2935d428a4807461f183034abe  pcre2-10.42.tar.bz2
29fcd2dec6bf5b48e5e3ffb3cbc4779e  nettle-3.9.1.tar.gz
269966167fa5bf8bae5f7534bcc3c454  gnutls-3.8.3.tar.xz
e7f7ca2f215b711f76584756ebd3c853  wget-1.21.4.tar.gz
8f28f7e08c91cc679a45fccf66184fbc  curl-8.6.0.tar.xz
9d7f059b1624d0a4d4b2f1781d08d600  LMDB_0.9.31.tar.gz
6f228a692516f5318a64505b46966cfa  cyrus-sasl-2.1.28.tar.gz
cf71b4b455ab8dfc8fdd4e247d697ccd  openldap-2.6.7.tgz
375d1a15ad969f32d25f1a7630929854  npth-1.6.tar.bz2
58e054ca192a77226c4822bbee1b7fdb  libgpg-error-1.47.tar.bz2
57b88e5d24c8705d9a3ba3832140d188  libksba-1.6.5.tar.bz2
a8cada0b343e10dbee51c9e92d856a94  libgcrypt-1.10.3.tar.bz2
9c22e76168675ec996b9d620ffbb7b27  libassuan-2.5.6.tar.bz2
be9b0d4bb493a139d2ec20e9b6872d37  pinentry-1.2.1.tar.bz2
114ac6367668a330ffae1ade6d79133a  gnupg-2.4.4.tar.bz2
7e4eb7c45e9ba7c90fa51deeea49732f  git-2.44.0.tar.xz
a7c927740e4964dd29b72cebfc1429bb  six-1.16.0.tar.gz
4a084d03915b271f67e9b8ea2ab24972  gdb-14.1.tar.xz
41a10af5fc35a7be472ae9864338e64a  Linux-PAM-1.6.0.tar.xz
452b0e59f08bf618482228ba3732d0ae  shadow-4.14.5.tar.xz
521cda27409a9edf0370c128fae3e690  systemd-255.tar.gz
5e90def5af3ffb27e149ca6fff12bef3  openssh-9.6p1.tar.gz
94c0b370f43123ea92b146ebea9c709d  icu4c-74_2-src.tgz
329138464b69422815c11e62acbc10dd  libxml2-2.12.5.tar.xz
97c1931900eee69ac6dd1e1c09f22e30  nghttp2-1.59.0.tar.xz
a808517c32ebd07c561bf21a4e30aeab  libuv-v1.48.0.tar.gz
39d3f3f9c55c87b1e5d6888e1420f4b5  lzo-2.10.tar.gz
4f4ef6a17c7b0b484aa2c95aa6deefac  libarchive-3.7.2.tar.xz
6b16c82b81e1fd80b63bee9696846b21  cmake-3.28.3.tar.gz
d32913b45d52459f40e6d434389e7bd4  fish-3.7.1.tar.xz
EOF
}

create_package_list () {
cat << EOF >> ./wget-list
https://anduin.linuxfromscratch.org/BLFS/blfs-bootscripts/blfs-bootscripts-20240209.tar.xz
https://www.linuxfromscratch.org/blfs/downloads/12.1-systemd/blfs-systemd-units-20240205.tar.xz
https://downloads.sourceforge.net/project/net-tools/net-tools-2.10.tar.xz
https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.19.0.tar.gz
https://github.com/p11-glue/p11-kit/releases/download/0.25.3/p11-kit-0.25.3.tar.xz
https://archive.mozilla.org/pub/nspr/releases/v4.35/src/nspr-4.35.tar.gz
https://sqlite.org/2024/sqlite-autoconf-3450100.tar.gz
https://archive.mozilla.org/pub/security/nss/releases/NSS_3_98_RTM/src/nss-3.98.tar.gz
https://www.linuxfromscratch.org/patches/blfs/12.1/nss-3.98-standalone-1.patch
https://github.com/lfs-book/make-ca/releases/download/v1.13/make-ca-1.13.tar.xz
https://ftp.gnu.org/gnu/libunistring/libunistring-1.1.tar.xz
https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz
https://github.com/rockdaboot/libpsl/releases/download/0.21.5/libpsl-0.21.5.tar.gz
https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.bz2
https://ftp.gnu.org/gnu/nettle/nettle-3.9.1.tar.gz
https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.3.tar.xz
https://ftp.gnu.org/gnu/nettle/nettle-3.9.1.tar.gz
https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz
https://curl.se/download/curl-8.6.0.tar.xz
https://files.pythonhosted.org/packages/source/s/six/six-1.16.0.tar.gz
https://ftp.gnu.org/gnu/gdb/gdb-14.1.tar.xz
https://github.com/shadow-maint/shadow/releases/download/4.14.5/shadow-4.14.5.tar.xz
https://github.com/linux-pam/linux-pam/releases/download/v1.6.0/Linux-PAM-1.6.0.tar.xz
https://github.com/systemd/systemd/archive/v255/systemd-255.tar.gz
https://www.linuxfromscratch.org/patches/blfs/12.1/systemd-255-upstream_fixes-1.patch
https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.6p1.tar.gz
https://github.com/LMDB/lmdb/archive/LMDB_0.9.31.tar.gz
https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.28/cyrus-sasl-2.1.28.tar.gz
https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.6.7.tgz
https://www.linuxfromscratch.org/patches/blfs/12.1/openldap-2.6.7-consolidated-1.patch
https://www.gnupg.org/ftp/gcrypt/npth/npth-1.6.tar.bz2
https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.47.tar.bz2
https://www.gnupg.org/ftp/gcrypt/libksba/libksba-1.6.5.tar.bz2
https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.10.3.tar.bz2
https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.6.tar.bz2
https://www.gnupg.org/ftp/gcrypt/pinentry/pinentry-1.2.1.tar.bz2
https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.4.4.tar.bz2
https://www.kernel.org/pub/software/scm/git/git-2.44.0.tar.xz
https://github.com/unicode-org/icu/releases/download/release-74-2/icu4c-74_2-src.tgz
https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.5.tar.xz
https://github.com/nghttp2/nghttp2/releases/download/v1.59.0/nghttp2-1.59.0.tar.xz
https://dist.libuv.org/dist/v1.48.0/libuv-v1.48.0.tar.gz
https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
https://github.com/libarchive/libarchive/releases/download/v3.7.2/libarchive-3.7.2.tar.xz
https://cmake.org/files/v3.28/cmake-3.28.3.tar.gz
https://github.com/fish-shell/fish-shell/releases/download/3.7.1/fish-3.7.1.tar.xz
EOF
}

# Download Packages
print_color "$TXT_BLUE" "Starting Download Package"

mkdir -pv $LFS/sources/_BLFS
chmod -v a+wt $LFS/sources/_BLFS

print_color "$TXT_BLUE" "Downloading Package..."

set +eu
apt-get install wget -y
create_package_list
wget --input-file=./wget-list --continue --directory-prefix=$LFS/sources/_BLFS;
rm ./wget-list
set -eu

print_color "$TXT_GREEN" "Packages Downloaded"
# Check package
print_color "$TXT_YELLOW" "Starting to Check if every package is here, otherwise download missing package manually."
pushd $LFS/sources/_BLFS
  create_md5sum
  md5sum -c md5sum
  rm md5sum
popd
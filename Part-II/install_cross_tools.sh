#!/bin/bash

TXT_RED="\033[1;31m"
TXT_GREEN="\033[1;32m"
TXT_YELLOW="\033[1;33m"
TXT_BLUE="\033[1;34m"
FANCY_RESET="\033[0m"

set -eu

user=$(whoami)

print_color () {
    echo -e "$1$2$FANCY_RESET"
}

handle_error() {
    print_color "$TXT_RED" "Error: line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR
if [ $user != "lfs" ]; then 
    echo "Please, Connect to lfs\n"
    exit 1
fi

print_color "$TXT_BLUE" "PASS 1 - STARTING"

cd /mnt/lfs/sources

##################binutils-2.42##################

tar xvf  binutils-2.42.tar.xz

pushd binutils-2.42
    mkdir -v build
    pushd build
        ../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-default-hash-style=gnu
        make
        make install
    popd
popd
rm -rf binutils-2.42

##################gcc-13.2.0 PASS1##################

tar xvf  gcc-13.2.0.tar.xz

pushd gcc-13.2.0
    tar -xf ../mpfr-4.2.1.tar.xz
    mv -v mpfr-4.2.1 mpfr
    tar -xf ../gmp-6.3.0.tar.xz
    mv -v gmp-6.3.0 gmp
    tar -xf ../mpc-1.3.1.tar.gz
    mv -v mpc-1.3.1 mpc

    case $(uname -m) in
        x86_64)
            sed -e '/m64=/s/lib64/lib/' \
                -i.orig gcc/config/i386/t-linux64
        ;;
    esac
    mkdir -v build
    pushd build
        ../configure                  \
            --target=$LFS_TGT         \
            --prefix=$LFS/tools       \
            --with-glibc-version=2.39 \
            --with-sysroot=$LFS       \
            --with-newlib             \
            --without-headers         \
            --enable-default-pie      \
            --enable-default-ssp      \
            --disable-nls             \
            --disable-shared          \
            --disable-multilib        \
            --disable-threads         \
            --disable-libatomic       \
            --disable-libgomp         \
            --disable-libquadmath     \
            --disable-libssp          \
            --disable-libvtv          \
            --disable-libstdcxx       \
            --enable-languages=c,c++
        make
        make install
    popd
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        `dirname \
            $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h
popd

##################Linux-6.7.4##################

tar xvf linux-6.7.4.tar.xz

pushd linux-6.7.4
    make mrproper
    make headers
    find usr/include -type f ! -name '*.h' -delete
    cp -rv usr/include $LFS/usr
popd
rm -rf linux-6.7.4

##################Glibc-2.39 PASS1##################

tar xvf glibc-2.39.tar.xz

pushd glibc-2.39
    case $(uname -m) in
        i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
        ;;
        x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
                ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
    esac
    patch -Np1 -i ../glibc-2.39-fhs-1.patch
    mkdir -v build
    pushd build
        echo "rootsbindir=/usr/sbin" > configparms
        ../configure                             \
            --prefix=/usr                      \
            --host=$LFS_TGT                    \
            --build=$(../scripts/config.guess) \
            --enable-kernel=4.19               \
            --with-headers=$LFS/usr/include    \
            --disable-nscd                     \
            libc_cv_slibdir=/usr/lib

        make
        make DESTDIR=$LFS install
        sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

        test1=$(echo 'int main(){}' | gcc -xc - -o a.out && readelf -l a.out | grep ld-linux)
        res='[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]'

        if [[ "$test1" == *"$res"* ]]; then
            echo -e "Test 1: OK\n"
            rm -rf a.out
        else
            echo -e "Test 1: \"$res\" is different than \"$test1\" failed exiting...\n"
            exit 1
        fi
    popd
popd
rm -rf glibc-2.39

#################Libstdc++ of GCC-13.2.0##################

pushd gcc-13.2.0
    rm -rf build/*
    pushd build
        ../libstdc++-v3/configure           \
            --host=$LFS_TGT                 \
            --build=$(../config.guess)      \
            --prefix=/usr                   \
            --disable-multilib              \
            --disable-nls                   \
            --disable-libstdcxx-pch         \
            --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/13.2.0
        make
        make DESTDIR=$LFS install
        rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
    popd
popd
rm -rf gcc-13.2.0

print_color "$TXT_GREEN" "PASS 1 - OK"


sleep 5


print_color "$TXT_BLUE" "PASS 2 - Starting"

#################M4-1.4.19##################

tar xvf m4-1.4.19.tar.xz

pushd m4-1.4.19
    ./configure --prefix=/usr   \
                --host=$LFS_TGT \
                --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
popd
rm -rf m4-1.4.19

##################Ncurses-6.4-20230520##################

tar xvf ncurses-6.4-20230520.tar.xz

pushd ncurses-6.4-20230520
    sed -i s/mawk// configure
    mkdir build
    pushd build
        ../configure
        make -C include
        make -C progs tic
    popd
    ./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            --enable-widec
    make
    make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
    ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
    sed -e 's/^#if.*XOPEN.*$/#if 1/' \
        -i $LFS/usr/include/curses.h
popd
rm -rf  ncurses-6.4-20230520

##################Bash-5.2.21##################

tar xvf bash-5.2.21.tar.gz

pushd bash-5.2.21
    ./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc
    make
    make DESTDIR=$LFS install
    ln -sv bash $LFS/bin/sh
popd
rm -rf bash-5.2.21

##################Coreutils-9.4##################

tar xvf coreutils-9.4.tar.xz

pushd coreutils-9.4
    ./configure --prefix=/usr                     \
                --host=$LFS_TGT                   \
                --build=$(build-aux/config.guess) \
                --enable-install-program=hostname \
                --enable-no-install-program=kill,uptime
    make
    make DESTDIR=$LFS install
    mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
    mkdir -pv $LFS/usr/share/man/man8
    mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8
popd
rm -rf coreutils-9.4.tar.gz

##################Diffutils-3.10##################

tar xvf diffutils-3.10.tar.xz

pushd diffutils-3.10
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
    make
    make DESTDIR=$LFS install
popd
rm -rf diffutils-3.10

##################File-5.45##################

tar xvf file-5.45.tar.gz

pushd file-5.45
    mkdir build
    pushd build
        ../configure --disable-bzlib      \
                    --disable-libseccomp \
                    --disable-xzlib      \
                    --disable-zlib
        make
    popd
    ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
    make FILE_COMPILE=$(pwd)/build/src/file
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/libmagic.la
popd
rm -rf file-5.45

##################Findutils-4.9.0##################

tar xvf findutils-4.9.0.tar.xz

pushd findutils-4.9.0
    ./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
popd
rm -rf findutils-4.9.0

##################Gawk-5.3.0##################

tar xvf gawk-5.3.0.tar.xz

pushd  gawk-5.3.0
    sed -i 's/extras//' Makefile.in
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
popd
rm -rf gawk-5.3.0

##################Grep-3.11##################

tar xvf grep-3.11.tar.xz

pushd grep-3.11 
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
    make
    make DESTDIR=$LFS install
popd
rm -rf grep-3.11 

##################Gzip-1.13##################

tar xvf gzip-1.13.tar.xz

pushd gzip-1.13
    ./configure --prefix=/usr --host=$LFS_TGT
    make
    make DESTDIR=$LFS install
popd
rm -rf gzip-1.13

##################Make-4.4.1##################

tar xvf make-4.4.1.tar.gz

pushd make-4.4.1 
    ./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
popd
rm -rf make-4.4.1

##################Patch-2.7.6##################
tar xvf patch-2.7.6.tar.xz

pushd patch-2.7.6
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
popd
rm -rf patch-2.7.6

##################Sed-4.9##################

tar xvf sed-4.9.tar.xz

pushd sed-4.9
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
    make
    make DESTDIR=$LFS install
popd
rm -rf sed-4.9

##################Tar-1.35##################

tar xvf tar-1.35.tar.xz

pushd tar-1.35 
    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
popd
rm -rf tar-1.35

##################Xz-5.4.6##################

tar xvf xz-5.4.6.tar.xz

pushd xz-5.4.6 
    ./configure --prefix=/usr                 \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.4.6
    make
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/liblzma.la
popd
rm -rf xz-5.4.6

##################Binutils-2.42 — Passe 2##################

tar xvf  binutils-2.42.tar.xz

pushd binutils-2.42
    sed '6009s/$add_dir//' -i ltmain.sh
    rm -rf build
    mkdir -v build
    pushd build
        ../configure               \
        --prefix=/usr              \
        --build=$(../config.guess) \
        --host=$LFS_TGT            \
        --disable-nls              \
        --enable-shared            \
        --enable-gprofng=no        \
        --disable-werror           \
        --enable-64-bit-bfd        \
        --enable-default-hash-style=gnu
        make
        make DESTDIR=$LFS install
        rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
    popd
popd
rm -rf binutils-2.42

##################GCC-13.2.0 — Passe 2##################

tar xvf  gcc-13.2.0.tar.xz

pushd gcc-13.2.0
    tar -xf ../mpfr-4.2.1.tar.xz
    mv -v mpfr-4.2.1 mpfr
    tar -xf ../gmp-6.3.0.tar.xz
    mv -v gmp-6.3.0 gmp
    tar -xf ../mpc-1.3.1.tar.gz
    mv -v mpc-1.3.1 mpc
    case $(uname -m) in
        x86_64)
            sed -e '/m64=/s/lib64/lib/' \
                -i.orig gcc/config/i386/t-linux64
        ;;
    esac
    sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
    mkdir -v build
    pushd build
        ../configure                                       \
            --build=$(../config.guess)                     \
            --host=$LFS_TGT                                \
            --target=$LFS_TGT                              \
            LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
            --prefix=/usr                                  \
            --with-build-sysroot=$LFS                      \
            --enable-default-pie                           \
            --enable-default-ssp                           \
            --disable-nls                                  \
            --disable-multilib                             \
            --disable-libatomic                            \
            --disable-libgomp                              \
            --disable-libquadmath                          \
            --disable-libsanitizer                         \
            --disable-libssp                               \
            --disable-libvtv                               \
            --enable-languages=c,c++
        make
        make DESTDIR=$LFS install
        ln -sv gcc $LFS/usr/bin/cc
    popd
popd
rm -rf gcc-13.2.0

print_color "$TXT_GREEN" "PASS 2 - OK"
print_color "$TXT_YELLOW" "Every Cross Compiling tools is sets, please disconnect from lfs user now"
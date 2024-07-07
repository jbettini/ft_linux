#!/bin/bash

set -eu

handle_error() {
    echo "Error: line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

user=$(whoami)
dir=$(pwd)

if [ $user != "lfs" ]; then 
    echo "Please, Connect to lfs\n"
    exit 1
fi

if [ $dir != "/mnt/lfs/sources" ]; then
    echo "Change the directory to /mnt/lfs/sources\n"
    cd /mnt/lfs/sources
fi

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

pushdg glibc-2.39
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

##################Libstdc++ of GCC-13.2.0##################

pushd gcc-13.2.0
    mkdir -v build
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
rm -rf

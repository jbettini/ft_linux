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
    echo -e "Please, Connect to lfs\n"
    exit 1
fi

if [ $dir != "/mnt/lfs/sources" ]; then
    echo -e "Change the directory to /mnt/lfs/sources"
    cd /mnt/lfs/sources
fi


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

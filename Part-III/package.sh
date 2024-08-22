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

set -eu

cd /sources

###############Man-pages-6.06##################

tar xvf man-pages-6.06.tar.xz

pushd man-pages-6.06
    rm -v man3/crypt*
    make prefix=/usr install
popd

rm -rf man-pages-6.06

#################Iana-Etc-20240125##################

tar xvf iana-etc-20240125.tar.gz

pushd iana-etc-20240125
    cp services protocols /etc
popd

rm -rf ian       echo "rootsbindir=/usr/sbin" > configparms
        ../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=4.19                     \
             --enable-stack-protector=strong          \
             --disable-nscd                           \
             libc_cv_slibdir=/usr/lib
        make
        touch /etc/ld.so.conf
        sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
        make install
        sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
        make localedata/install-locales
        localedef -i C -f UTF-8 C.UTF-8
        localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
        cat > /etc/nsswitch.conf << "EOF"
# Début de /etc/nsswitch.conf

passwd: files systemd
group: files systemd
shadow: files systemd

hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# Fin de /etc/nsswitch.conf
EOF
        tar -xf ../../tzdata2024a.tar.gz

        ZONEINFO=/usr/share/zoneinfo
        mkdir -pv $ZONEINFO/{posix,right}

        for tz in etcetera southamerica northamerica europe africa antarctica  \
                asia australasia backward; do
            zic -L /dev/null   -d $ZONEINFO       ${tz}
            zic -L /dev/null   -d $ZONEINFO/posix ${tz}
            zic -L leapseconds -d $ZONEINFO/right ${tz}
        done

        cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
        zic -d $ZONEINFO -p Europe/Paris
        unset ZONEINFO
        tzselect << EOF
7
15
1
EOF
        ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime
        cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF
        cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
        mkdir -pv /etc/ld.so.conf.d
    popd
popd

rm -rf glibc-2.39

#################Zlib-1.3.1##################

tar xvf zlib-1.3.1.tar.gz

pushd zlib-1.3.1
    ./configure --prefix=/usr
    make
    make install
    rm -fv /usr/lib/libz.a
popd

rm -rf zlib-1.3.1

#################Bzip2-1.0.8##################

tar xvf bzip2-1.0.8.tar.gz

pushd bzip2-1.0.8
    patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
    sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
    sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
    make -f Makefile-libbz2_so
    make clean
    make
    make PREFIX=/usr install
    cp -av libbz2.so.* /usr/lib
    ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
    cp -v bzip2-shared /usr/bin/bzip2
    for i in /usr/bin/{bzcat,bunzip2}; do
        ln -sfv bzip2 $i
    done
    rm -fv /usr/lib/libbz2.a
popd

rm -rf bzip2-1.0.8

#################Xz-5.4.6##################

tar xvf xz-5.4.6.tar.xz

pushd xz-5.4.6
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.4.6
    make
    make install
popd

rm -rf xz-5.4.6

#################Zstd-1.5.5##################

tar xvf zstd-1.5.5.tar.gz

pushd zstd-1.5.5
    make prefix=/usr
    make prefix=/usr install
    rm -v /usr/lib/libzstd.a
popd

rm -rf zstd-1.5.5

###############File-5.45##################

tar xvf file-5.45.tar.gz

pushd file-5.45
    ./configure --prefix=/usr
    make
    make install
popd

rm -rf file-5.45

#################Readline-8.2##################

tar xvf readline-8.2.tar.gz

pushd readline-8.2
    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install
    patch -Np1 -i ../readline-8.2-upstream_fixes-3.patch
    ./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.2
    make SHLIB_LIBS="-lncursesw"
    make SHLIB_LIBS="-lncursesw" install
    install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2
popd

rm -rf readline-8.2

#################M4-1.4.19##################

tar xvf m4-1.4.19.tar.xz

pushd m4-1.4.19
    ./configure --prefix=/usr
    make
    make install
popd

rm -rf m4-1.4.19

#################Bc-6.7.5##################

tar xvf bc-6.7.5.tar.xz

pushd bc-6.7.5
    CC=gcc ./configure --prefix=/usr -G -O3 -r
    make

    make install
popd

rm -rf bc-6.7.5

#################Flex-2.6.4##################

tar xvf flex-2.6.4.tar.gz

pushd flex-2.6.4
    ./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static
    make
    make install
    ln -sv flex   /usr/bin/lex
    ln -sv flex.1 /usr/share/man/man1/lex.1
popd

rm -rf flex-2.6.4

################Tcl-8.6.13##################

tar xvf tcl8.6.13-src.tar.gz

pushd tcl8.6.13
    SRCDIR=$(pwd)
    cd unix
    ./configure --prefix=/usr           \
                --mandir=/usr/share/man
    make

    sed -e "s|$SRCDIR/unix|/usr/lib|" \
        -e "s|$SRCDIR|/usr/include|"  \
        -i tclConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.5|/usr/lib/tdbc1.1.5|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.5/generic|/usr/include|"    \
        -e "s|$SRCDIR/pkgs/tdbc1.1.5/library|/usr/lib/tcl8.6|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.5|/usr/include|"            \
        -i pkgs/tdbc1.1.5/tdbcConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.3|/usr/lib/itcl4.2.3|" \
        -e "s|$SRCDIR/pkgs/itcl4.2.3/generic|/usr/include|"    \
        -e "s|$SRCDIR/pkgs/itcl4.2.3|/usr/include|"            \
        -i pkgs/itcl4.2.3/itclConfig.sh

    unset SRCDIR


    make install
    chmod -v u+w /usr/lib/libtcl8.6.so
    make install-private-headers
    ln -sfv tclsh8.6 /usr/bin/tclsh
    mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
    cd ..
    tar -xf ../tcl8.6.13-html.tar.gz --strip-components=1
    mkdir -v -p /usr/share/doc/tcl-8.6.13
    cp -v -r  ./html/* /usr/share/doc/tcl-8.6.13
popd

rm -rf tcl8.6.13

#################Expect-5.45.4##################

tar xvf expect5.45.4.tar.gz

pushd expect5.45.4
    python3 -c 'from pty import spawn; spawn(["echo", "ok"])'
    ./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
    make

    make install
    ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
popd

rm -rf expect5.45.4

#################DejaGNU-1.6.3##################

tar xvf dejagnu-1.6.3.tar.gz

pushd dejagnu-1.6.3
    mkdir -pv build
    pushd build
        ../configure --prefix=/usr
        makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
        makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi        
        make install
        install -v -dm755  /usr/share/doc/dejagnu-1.6.3
        install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
    popd
popd

rm -rf dejagnu-1.6.3

#################Pkgconf-2.1.1##################

tar xvf pkgconf-2.1.1.tar.xz

pushd pkgconf-2.1.1
    ./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.1.1
    make
    make install
    ln -sv pkgconf   /usr/bin/pkg-config
    ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1 
popd

rm -rf pkgconf-2.1.1a-etc-20240125

################Glibc-2.39##################

tar xvf glibc-2.39.tar.xz

pushd glibc-2.39
    patch -Np1 -i ../glibc-2.39-fhs-1.patch
    mkdir -pv build
    pushd build
 

# ################Binutils-2.42##################

tar xvf binutils-2.42.tar.xz

pushd binutils-2.42
    mkdir -pv build
    pushd build
        ../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib  \
             --enable-default-hash-style=gnu
        make tooldir=/usr
        make tooldir=/usr install
        rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a
    popd
popd

rm -rf binutils-2.42

# ###############GMP-6.3.0##################

tar xvf gmp-6.3.0.tar.xz

pushd gmp-6.3.0
    ./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0
    make
    make html
    make install
    make install-html
popd

rm -rf gmp-6.3.0

################MPFR-4.2.1##################
tar xvf mpfr-4.2.1.tar.xz

pushd mpfr-4.2.1
    ./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.1
    make
    make html
    make install
    make install-html
popd

rm -rf mpfr-4.2.1

################MPC-1.3.1##################

tar xvf mpc-1.3.1.tar.gz

pushd mpc-1.3.1
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1
    make
    make html
    make install
    make install-html
popd

rm -rf mpc-1.3.1

################Attr-2.5.2##################

tar xvf attr-2.5.2.tar.gz

pushd attr-2.5.2 
    ./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2
    make
    make install

popd

rm -rf attr-2.5.2 

###############Acl-2.3.2.tar.xz##################

tar xvf acl-2.3.2.tar.xz

pushd acl-2.3.2
    ./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.2
    make
    make install
popd

rm -rf acl-2.3.2

################Libcap-2.69##################

tar xvf libcap-2.69.tar.xz

pushd libcap-2.69
    sed -i '/install -m.*STA/d' libcap/Makefile
    make prefix=/usr lib=lib
    make prefix=/usr lib=lib install
popd

rm -rf libcap-2.69

################Libxcrypt-4.4.36##################

tar xvf libxcrypt-4.4.36.tar.xz

pushd libxcrypt-4.4.36
    ./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens
    make
    make install
popd

rm -rf libxcrypt-4.4.36

################Shadow-4.14.5.tar.xz##################

tar xvf shadow-4.14.5.tar.xz

pushd shadow-4.14.5
    sed -i 's/groups$(EXEEXT) //' src/Makefile.in
    find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
    find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
    find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

    sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs

    touch /usr/bin/passwd
    ./configure --sysconfdir=/etc   \
                --disable-static    \
                --with-{b,yes}crypt \
                --without-libbsd    \
                --with-group-name-max-length=32
    
    make exec_prefix=/usr install
    make -C man install-man

    pwconv
    grpconv

    mkdir -p /etc/default
    useradd -D --gid 999
    sed -i '/MAIL/s/yes/no/' /etc/default/useradd
cat << EOF > /tmp/rootpasswd
root:root
EOF
    chpasswd < /tmp/rootpasswd
    rm /tmp/rootpasswd

popd

rm -rf shadow-4.14.5

###############GCC-13.2.0 ##################

tar xvf gcc-13.2.0.tar.xz

pushd gcc-13.2.0
    case $(uname -m) in x86_64)
        sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
        ;;
    esac
    mkdir -pv build
    pushd build
        ../configure --prefix=/usr      \
             LD=ld                      \
             --enable-languages=c,c++   \
             --enable-default-pie       \
             --enable-default-ssp       \
             --disable-multilib         \
             --disable-bootstrap        \
             --disable-fixincludes      \
             --with-system-zlib         \
             --with-gmp=/usr                 \
             --with-mpfr=/usr                \
             --with-mpc
        make
        ulimit -s 32768
        chown -R tester .
        # Warning set -j<num of cores> to ur cores number
        ../contrib/test_summary
        make install
        chown -v -R root:root \
        /usr/lib/gcc/$(gcc -dumpmachine)/13.2.0/include{,-fixed}
        ln -svr /usr/bin/cpp /usr/lib
        ln -sv gcc.1 /usr/share/man/man1/cc.1
        ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/13.2.0/liblto_plugin.so /usr/lib/bfd-plugins/

        test1=$(echo 'int main(){}' > dummy.c;
                cc dummy.c -v -Wl,--verbose &> dummy.log;
                readelf -l a.out | grep ': /lib')
        res='[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]'
        if [[ "$test1" == *"$res"* ]]; then
            echo -e "GCC Test 1: OK\n"
            rm -rf a.out
        else
            echo -e "GCC Test 1: \"$res\"\n is different than :\n \"$test1\" failed exiting...\n"
            exit 1
        fi

        test2=$(grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log)
        res2=$(echo -e "/usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/../../../../lib/Scrt1.o succeeded\n/usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/../../../../lib/crti.o succeeded\n/usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/../../../../lib/crtn.o succeeded")
        if [[ "$test2" == *"$res2"* ]]; then
            echo -e "GCC Test 2: OK\n"
        else
            echo -e "GCC Test 2: \"$res2\"\n is different than :\n \"$test2\" failed exiting...\n"
            exit 1
        fi

        test3=$(grep -B4 '^ /usr/include' dummy.log)
        res3="#include <...> search starts here:
 /usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/include
 /usr/local/include
 /usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/include-fixed
 /usr/include"
        if [[ "$test3" == *"$res3"* ]]; then
            echo -e "GCC Test 3: OK\n"
        else
            echo -e "GCC Test 3: \"$res3\"\n is different than :\n \"$test3\" failed exiting...\n"
            exit 1
        fi


        test4=$(grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g')
        res4="SEARCH_DIR(\"/usr/x86_64-pc-linux-gnu/lib64\")
SEARCH_DIR(\"/usr/local/lib64\")
SEARCH_DIR(\"/lib64\")
SEARCH_DIR(\"/usr/lib64\")
SEARCH_DIR(\"/usr/x86_64-pc-linux-gnu/lib\")
SEARCH_DIR(\"/usr/local/lib\")
SEARCH_DIR(\"/lib\")
SEARCH_DIR(\"/usr/lib\");"
        if [[ "$test4" == *"$res4"* ]]; then
            echo -e "GCC Test 4: OK\n"
        else
            echo -e "GCC Test 4: \"$res4\"\n is different than :\n \"$test4\" failed exiting...\n"
            exit 1
        fi

        
        test5=$(grep "/lib.*/libc.so.6 " dummy.log)
        res5=$(echo -e "attempt to open /usr/lib/libc.so.6 succeeded")
        if [[ "$test5" == *"$res5"* ]]; then
            echo -e "GCC Test 5: OK\n"
        else
            echo -e "GCC Test 5: \"$res5\"\n is different than :\n \"$test5\" failed exiting...\n"
            exit 1
        fi

        test6=$(grep "/lib.*/libc.so.6 " dummy.log)
        res6=$(echo -e "attempt to open /usr/lib/libc.so.6 succeeded")
        if [[ "$test6" == *"$res6"* ]]; then
            echo -e "GCC Test 6: OK\n"
        else
            echo -e "GCC Test 6: \"$res6\"\n is different than :\n \"$test6\" failed exiting...\n"
            exit 1
        fi

        test7=$(grep found dummy.log)
        res7=$(echo -e "found ld-linux-x86-64.so.2 at /usr/lib/ld-linux-x86-64.so.2")
        if [[ "$test7" == *"$res7"* ]]; then
            echo -e "GCC Test 7: OK\n"
        else
            echo -e "GCC Test 7: \"$res7\"\n is different than :\n \"$test7\" failed exiting...\n"
            exit 1
        fi

        mkdir -pv /usr/share/gdb/auto-load/usr/lib
        mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
    popd
popd

rm -rf gcc-13.2.0

###############Ncurses-6.4-20230520.tar.xz##################

tar xvf ncurses-6.4-20230520.tar.xz

pushd ncurses-6.4-20230520
    ./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --enable-widec          \
            --with-pkg-config-libdir=/usr/lib/pkgconfig
    make
    make DESTDIR=$PWD/dest install
    install -vm755 dest/usr/lib/libncursesw.so.6.4 /usr/lib
    rm -v  dest/usr/lib/libncursesw.so.6.4
    sed -e 's/^#if.*XOPEN.*$/#if 1/' \
        -i dest/usr/include/curses.h
    cp -av dest/* /
    for lib in ncurses form panel menu ; do
        ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
        ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
    done
    ln -sfv libncursesw.so /usr/lib/libcurses.so
    cp -v -R doc -T /usr/share/doc/ncurses-6.4-20230520
popd

rm -rf ncurses-6.4-20230520

###############Sed-4.9##################

tar xvf sed-4.9.tar.xz

pushd sed-4.9
    set +e
    ./configure --prefix=/usr
    make
    make html
    make install
    install -d -m755           /usr/share/doc/sed-4.9
    install -m644 doc/sed.html /usr/share/doc/sed-4.9
    set -e
popd

rm -rf sed-4.9

###############Psmisc-23.6##################

tar xvf psmisc-23.6.tar.xz

pushd psmisc-23.6
    ./configure --prefix=/usr
    make
    make install
popd

rm -rf psmisc-23.6

###############Gettext-0.22.4.tar.xz##################

tar xvf gettext-0.22.4.tar.xz

pushd gettext-0.22.4
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.22.4
    make
    make install
    chmod -v 0755 /usr/lib/preloadable_libintl.so

popd

rm -rf gettext-0.22.4

###############Bison-3.8.2##################

tar xvf bison-3.8.2.tar.xz

pushd bison-3.8.2
    ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
    make
    make install
popd

rm -rf bison-3.8.2

###############Grep-3.11##################

tar xvf grep-3.11.tar.xz

pushd grep-3.11
    sed -i "s/echo/#echo/" src/egrep.sh
    ./configure --prefix=/usr
    make
    make install
popd

rm -rf grep-3.11

###############Bash-5.2.21##################

tar xvf bash-5.2.21.tar.gz

pushd bash-5.2.21
    patch -Np1 -i ../bash-5.2.21-upstream_fixes-1.patch
    ./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.2.21
    make
    make install
popd

rm -rf bash-5.2.21

print_color "$TXT_YELLOW" "Fisrst Part of package Finish, Now just execute the second script"

exec /usr/bin/bash --login

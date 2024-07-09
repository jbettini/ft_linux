#!/bin/bash

set -eu

handle_error() {
    echo "Error: line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

cd /sources

run_make_check() {
    set +e 
    $1
    make check 2>&1 | tee check-log
    set -e
    total_pass=$(awk '/# PASS:/{total+=$3} ; END{print total}' check-log)
    total_succ=$(awk '/# SUCESS:/{total+=$3} ; END{print total}' check-log)
    total_fail=$(awk '/# FAIL:/{total+=$3} ; END{print total}' check-log)

    total_pass=${total_pass:-0}
    total_succ=${total_succ:-0}
    total_fail=${total_fail:-0}

    total_tests=$(total_pass + total_succ + total_tests)
    ratio_fail=$(total_fail * 100 / total_tests)
    if [ $ratio_fail -gt 7 ]; then
        echo "a check failed"
        exit 1
    fi
}


# #################Man-pages-6.06##################

# # tar xvf man-pages-6.06.tar.xz

# # pushd man-pages-6.06
# #     rm -v man3/crypt*
# #     make prefix=/usr install
# # popd

# # rm -rf man-pages-6.06

# # #################Iana-Etc-20240125##################

# # tar xvf iana-etc-20240125.tar.gz

# # pushd iana-etc-20240125
# #     cp services protocols /etc
# # popd

# # rm -rf iana-etc-20240125

# #################Glibc-2.39##################

# # tar xvf glibc-2.39.tar.xz

# # pushd glibc-2.39
# #     patch -Np1 -i ../glibc-2.39-fhs-1.patch
# #     mkdir -v build
# #     pushd build
# #         echo "rootsbindir=/usr/sbin" > configparms
# #         ../configure --prefix=/usr                            \
# #              --disable-werror                         \
# #              --enable-kernel=4.19                     \
# #              --enable-stack-protector=strong          \
# #              --disable-nscd                           \
# #              libc_cv_slibdir=/usr/lib
# #         make
# #         touch /etc/ld.so.conf
# #         sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
        
# #         run_make_check "check"
        
# #         make install
# #         sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
# #         make localedata/install-locales
# #         localedef -i C -f UTF-8 C.UTF-8
# #         localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
# #         cat > /etc/nsswitch.conf << "EOF"
# # # Début de /etc/nsswitch.conf

# # passwd: files systemd
# # group: files systemd
# # shadow: files systemd

# # hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
# # networks: files

# # protocols: files
# # services: files
# # ethers: files
# # rpc: files

# # # Fin de /etc/nsswitch.conf
# # EOF
# #         tar -xf ../../tzdata2024a.tar.gz

# #         ZONEINFO=/usr/share/zoneinfo
# #         mkdir -pv $ZONEINFO/{posix,right}

# #         for tz in etcetera southamerica northamerica europe africa antarctica  \
# #                 asia australasia backward; do
# #             zic -L /dev/null   -d $ZONEINFO       ${tz}
# #             zic -L /dev/null   -d $ZONEINFO/posix ${tz}
# #             zic -L leapseconds -d $ZONEINFO/right ${tz}
# #         done

# #         cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
# #         zic -d $ZONEINFO -p Europe/Paris
# #         unset ZONEINFO
# #         tzselect
# #         7
# #         15
# #         1
# #         ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime
# #         cat > /etc/ld.so.conf << "EOF"
# # # Begin /etc/ld.so.conf
# # /usr/local/lib
# # /opt/lib

# # EOF
# #         cat >> /etc/ld.so.conf << "EOF"
# # # Add an include directory
# # include /etc/ld.so.conf.d/*.conf

# # EOF
# #         mkdir -pv /etc/ld.so.conf.d
# #     popd
# # popd

# # rm -rf glibc-2.39

# #################Zlib-1.3.1##################

# tar xvf zlib-1.3.1.tar.gz

# pushd zlib-1.3.1
#     ./configure --prefix=/usr
#     make

#     run_make_check "check"

#     make install
#     rm -fv /usr/lib/libz.a
# popd

# rm -rf zlib-1.3.1

# #################Bzip2-1.0.8##################

# tar xvf bzip2-1.0.8.tar.gz

# pushd bzip2-1.0.8
#     patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
#     sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
#     sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
#     make -f Makefile-libbz2_so
#     make clean
#     make
#     make PREFIX=/usr install
#     cp -av libbz2.so.* /usr/lib
#     ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
#     cp -v bzip2-shared /usr/bin/bzip2
#     for i in /usr/bin/{bzcat,bunzip2}; do
#         ln -sfv bzip2 $i
#     done
#     rm -fv /usr/lib/libbz2.a
# popd

# rm -rf bzip2-1.0.8

# #################Xz-5.4.6##################

# tar xvf xz-5.4.6.tar.xz

# pushd xz-5.4.6
#     ./configure --prefix=/usr    \
#             --disable-static \
#             --docdir=/usr/share/doc/xz-5.4.6
#     make
#     run_make_check "check"
#     make install
# popd

# rm -rf xz-5.4.6

# #################Zstd-1.5.5##################

# tar xvf zstd-1.5.5.tar.gz

# pushd zstd-1.5.5
#     make prefix=/usr
#     run_make_check "check"
#     make prefix=/usr install
#     rm -v /usr/lib/libzstd.a
# popd

# rm -rf zstd-1.5.5

# #################File-5.45##################

# tar xvf file-5.45.tar.gz

# pushd file-5.45
#     ./configure --prefix=/usr
#     make
#     run_make_check "check"
#     make install
# popd

# rm -rf file-5.45

# #################Readline-8.2##################

# tar xvf readline-8.2.tar.gz

# pushd readline-8.2
#     sed -i '/MV.*old/d' Makefile.in
#     sed -i '/{OLDSUFF}/c:' support/shlib-install
#     patch -Np1 -i ../readline-8.2-upstream_fixes-3.patch
#     ./configure --prefix=/usr    \
#             --disable-static \
#             --with-curses    \
#             --docdir=/usr/share/doc/readline-8.2
#     make SHLIB_LIBS="-lncursesw"
#     make SHLIB_LIBS="-lncursesw" install
#     install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2
# popd

# rm -rf readline-8.2

# #################M4-1.4.19##################

# tar xvf m4-1.4.19.tar.xz

# pushd m4-1.4.19
#     ./configure --prefix=/usr
#     make
#     run_make_check "check"
#     make install
# popd

# rm -rf m4-1.4.19

# #################Bc-6.7.5##################

# tar xvf bc-6.7.5.tar.xz

# pushd bc-6.7.5
#     CC=gcc ./configure --prefix=/usr -G -O3 -r
#     make
#     run_make_check "test"
#     make install
# popd

# rm -rf bc-6.7.5

# #################Flex-2.6.4##################

# tar xvf flex-2.6.4.tar.gz

# pushd flex-2.6.4
#     ./configure --prefix=/usr \
#             --docdir=/usr/share/doc/flex-2.6.4 \
#             --disable-static
#     make
#     run_make_check "check"
#     make install
#     ln -sv flex   /usr/bin/lex
#     ln -sv flex.1 /usr/share/man/man1/lex.1
# popd

# rm -rf flex-2.6.4

#################Tcl-8.6.13##################

# tar xvf tcl8.6.13-src.tar.gz

# pushd tcl8.6.13
#     SRCDIR=$(pwd)
#     cd unix
#     ./configure --prefix=/usr           \
#                 --mandir=/usr/share/man
#     make

#     sed -e "s|$SRCDIR/unix|/usr/lib|" \
#         -e "s|$SRCDIR|/usr/include|"  \
#         -i tclConfig.sh

#     sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.5|/usr/lib/tdbc1.1.5|" \
#         -e "s|$SRCDIR/pkgs/tdbc1.1.5/generic|/usr/include|"    \
#         -e "s|$SRCDIR/pkgs/tdbc1.1.5/library|/usr/lib/tcl8.6|" \
#         -e "s|$SRCDIR/pkgs/tdbc1.1.5|/usr/include|"            \
#         -i pkgs/tdbc1.1.5/tdbcConfig.sh

#     sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.3|/usr/lib/itcl4.2.3|" \
#         -e "s|$SRCDIR/pkgs/itcl4.2.3/generic|/usr/include|"    \
#         -e "s|$SRCDIR/pkgs/itcl4.2.3|/usr/include|"            \
#         -i pkgs/itcl4.2.3/itclConfig.sh

#     unset SRCDIR

#     run_make_check "test"
#     make install
#     chmod -v u+w /usr/lib/libtcl8.6.so
#     make install-private-headers
#     ln -sfv tclsh8.6 /usr/bin/tclsh
#     mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
#     cd ..
#     tar -xf ../tcl8.6.13-html.tar.gz --strip-components=1
#     mkdir -v -p /usr/share/doc/tcl-8.6.13
#     cp -v -r  ./html/* /usr/share/doc/tcl-8.6.13
# popd

# rm -rf tcl8.6.13

# #################Expect-5.45.4##################

# tar xvf expect5.45.4.tar.gz

# pushd expect5.45.4
#     python3 -c 'from pty import spawn; spawn(["echo", "ok"])'
#     ./configure --prefix=/usr           \
#             --with-tcl=/usr/lib     \
#             --enable-shared         \
#             --mandir=/usr/share/man \
#             --with-tclinclude=/usr/include
#     make
#     run_make_check "test"
#     make install
#     ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
# popd

# rm -rf expect5.45.4

# #################DejaGNU-1.6.3##################

# tar xvf dejagnu-1.6.3.tar.gz

# pushd dejagnu-1.6.3
#     mkdir -v build
#     pushd build
#         ../configure --prefix=/usr
#         makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
#         makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi
#         run_make_check "check"
#         make install
#         install -v -dm755  /usr/share/doc/dejagnu-1.6.3
#         install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
#     popd
# popd

# rm -rf dejagnu-1.6.3

# #################Pkgconf-2.1.1##################

# tar xvf pkgconf-2.1.1.tar.xz

# pushd pkgconf-2.1.1
#     ./configure --prefix=/usr              \
#             --disable-static           \
#             --docdir=/usr/share/doc/pkgconf-2.1.1
#     make
#     make install
#     ln -sv pkgconf   /usr/bin/pkg-config
#     ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1 
# popd

# rm -rf pkgconf-2.1.1

# #################Binutils-2.42##################

# tar xvf binutils-2.42.tar.xz

# pushd binutils-2.42
#     mkdir -v build
#     pushd build
#         ../configure --prefix=/usr       \
#              --sysconfdir=/etc   \
#              --enable-gold       \
#              --enable-ld=default \
#              --enable-plugins    \
#              --enable-shared     \
#              --disable-werror    \
#              --enable-64-bit-bfd \
#              --with-system-zlib  \
#              --enable-default-hash-style=gnu
#         make tooldir=/usr
#         set +e
#         make -k check
#         make tooldir=/usr install
#         set -e
#         rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a
#     popd
# popd

# rm -rf binutils-2.42

#################GMP-6.3.0##################

# tar xvf gmp-6.3.0.tar.xz

# pushd gmp-6.3.0
#     ./configure --prefix=/usr    \
#             --enable-cxx     \
#             --disable-static \
#             --docdir=/usr/share/doc/gmp-6.3.0
#     make
#     make html
#     set +e
#     make check 2>&1 | tee gmp-check-log
#     set -e
#     total_passed=$(awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log)
#     if [ "total_passed" -lt 199 ]; then
#         echo "check for gmp failed"
#         exit 1
#     fi

#     make install
#     make install-html
# popd

# rm -rf gmp-6.3.0

# #################MPFR-4.2.1##################
# tar xvf mpfr-4.2.1.tar.xz

# pushd mpfr-4.2.1
#     ./configure --prefix=/usr        \
#             --disable-static     \
#             --enable-thread-safe \
#             --docdir=/usr/share/doc/mpfr-4.2.1
#     make
#     make html
#     # Check if minimum of 198 pass
#     set +e
#     make check 2>&1 | tee mpfr-check-log
#     set -e
#     total_passed=$(awk '/# PASS:/{total+=$3} ; END{print total}' mpfr-check-log)
#     if [ "total_passed" -lt 199 ]; then
#         echo "check for gmp failed"
#         exit 1
#     fi
#     make install
#     make install-html
# popd

# rm -rf mpfr-4.2.1

# #################MPC-1.3.1##################

tar xvf mpc-1.3.1.tar.gz

pushd mpc-1.3.1
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1
    make
    make html
    run_make_check "make check"
    make install
    make install-html
popd

rm -rf mpc-1.3.1

# #################Attr-2.5.2##################

# tar xvf attr-2.5.2.tar.gz

# pushd attr-2.5.2 
#     ./configure --prefix=/usr     \
#             --disable-static  \
#             --sysconfdir=/etc \
#             --docdir=/usr/share/doc/attr-2.5.2
#     make
#     run_make_check "make check"
#     make install

# popd

# rm -rf attr-2.5.2 

#################Acl-2.3.2.tar.xz##################

# tar xvf acl-2.3.2.tar.xz

# pushd acl-2.3.2
#     ./configure --prefix=/usr         \
#             --disable-static      \
#             --docdir=/usr/share/doc/acl-2.3.2
#     make
#     make install
# popd

# rm -rf acl-2.3.2

# #################Libcap-2.69##################

# tar xvf libcap-2.69.tar.xz

# pushd libcap-2.69
#     sed -i '/install -m.*STA/d' libcap/Makefile
#     make prefix=/usr lib=lib
#     run_make_check "make test"
#     make prefix=/usr lib=lib install
# popd

# rm -rf libcap-2.69

# #################Libxcrypt-4.4.36##################

# tar xvf libxcrypt-4.4.36.tar.xz

# pushd libxcrypt-4.4.36
#     ./configure --prefix=/usr                \
#             --enable-hashes=strong,glibc \
#             --enable-obsolete-api=no     \
#             --disable-static             \
#             --disable-failure-tokens
#     make
#     run_make_check "make check"
#     make install
# popd

# rm -rf libxcrypt-4.4.36

# #################Shadow-4.14.5.tar.xz##################

# tar xvf shadow-4.14.5.tar.xz

# pushd shadow-4.14.5
#     sed -i 's/groups$(EXEEXT) //' src/Makefile.in
#     find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
#     find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
#     find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

#     sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
#     -e 's:/var/spool/mail:/var/mail:'                   \
#     -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
#     -i etc/login.defs

#     touch /usr/bin/passwd
#     ./configure --sysconfdir=/etc   \
#                 --disable-static    \
#                 --with-{b,yes}crypt \
#                 --without-libbsd    \
#                 --with-group-name-max-length=32
    
#     make exec_prefix=/usr install
#     make -C man install-man

#     pwconv
#     grpconv

#     mkdir -p /etc/default
#     useradd -D --gid 999
#     sed -i '/MAIL/s/yes/no/' /etc/default/useradd

#     # if u want to choose a password to root uncomment the next line
#     #passwd root

# popd

# rm -rf shadow-4.14.5

#################GCC-13.2.0 ##################

tar xvf gcc-13.2.0.tar.xz

pushd gcc-13.2.0
    case $(uname -m) in x86_64)
        sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
        ;;
    esac
    mkdir -v build
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
        ## Warning set -j<num of cores> to ur cores number
        set +e
        su tester -c "PATH=$PATH make -k -j4 check"
        set -e
        ../contrib/test_summary
        make install
        chown -v -R root:root \
        /usr/lib/gcc/$(gcc -dumpmachine)/13.2.0/include{,-fixed}
        ln -svr /usr/bin/cpp /usr/lib
        ln -sv gcc.1 /usr/share/man/man1/cc.1
        ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/13.2.0/liblto_plugin.so /usr/lib/bfd-plugins/

        test1=$(echo 'int main(){}' > dummy.c | cc dummy.c -v -Wl,--verbose &> dummy.log | readelf -l a.out | grep ': /lib')
        res='[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]'
        if [[ "$test1" == *"$res"* ]]; then
            echo -e "GCC Test 1: OK\n"
            rm -rf a.out
        else
            echo -e "GCC Test 1: \"$res\" is different than \"$test1\" failed exiting...\n"
            exit 1
        fi

        test2=$(grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log)
        res2=$(echo -e "/usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/../../../../lib/Scrt1.o succeeded\n/usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/../../../../lib/crti.o succeeded\n/usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/../../../../lib/crtn.o succeeded")
        if [[ "$test2" == *"$res2"* ]]; then
            echo -e "GCC Test 2: OK\n"
        else
            echo -e "GCC Test 2: \"$res2\" is different than \"$test2\" failed exiting...\n"
            exit 1
        fi

        test3=$(grep -B4 '^ /usr/include' dummy.log)
        res3=$(echo -e "#include <...> search starts here:\n/usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/include\n/usr/local/include\n/usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/include-fixed\n/usr/include")
        if [[ "$test3" == *"$res3"* ]]; then
            echo -e "GCC Test 3: OK\n"
        else
            echo -e "GCC Test 3: \"$res3\" is different than \"$test3\" failed exiting...\n"
            exit 1
        fi


        test4=$(grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g')
        res4=$(echo -e "SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib64")\nSEARCH_DIR("/usr/local/lib64")\nSEARCH_DIR("/lib64")\nSEARCH_DIR("/usr/lib64")\nSEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib")\nSEARCH_DIR("/usr/local/lib")\nSEARCH_DIR("/lib")\nSEARCH_DIR("/usr/lib");")
        if [[ "$test4" == *"$res4"* ]]; then
            echo -e "GCC Test 4: OK\n"
        else
            echo -e "GCC Test 4: \"$res4\" is different than \"$test4\" failed exiting...\n"
            exit 1
        fi

        
        test5=$(grep "/lib.*/libc.so.6 " dummy.log)
        res5=$(echo -e "attempt to open /usr/lib/libc.so.6 succeeded")
        if [[ "$test5" == *"$res5"* ]]; then
            echo -e "GCC Test 5: OK\n"
        else
            echo -e "GCC Test 5: \"$res5\" is different than \"$test5\" failed exiting...\n"
            exit 1
        fi

        test6=$(grep "/lib.*/libc.so.6 " dummy.log)
        res6=$(echo -e "attempt to open /usr/lib/libc.so.6 succeeded")
        if [[ "$test6" == *"$res6"* ]]; then
            echo -e "GCC Test 6: OK\n"
        else
            echo -e "GCC Test 6: \"$res6\" is different than \"$test6\" failed exiting...\n"
            exit 1
        fi

        test7=$(grep found dummy.log)
        res7=$(echo -e "found ld-linux-x86-64.so.2 at /usr/lib/ld-linux-x86-64.so.2")
        if [[ "$test7" == *"$res7"* ]]; then
            echo -e "GCC Test 7: OK\n"
        else
            echo -e "GCC Test 7: \"$res7\" is different than \"$test7\" failed exiting...\n"
            exit 1
        fi

        rm -v dummy.c a.out dummy.log
        mkdir -pv /usr/share/gdb/auto-load/usr/lib
        mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
    popd
popd

rm -rf gcc-13.2.0

#################Ncurses-6.4-20230520.tar.xz##################

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

    #  Les instructions ci-dessus ne créent pas de bibliothèques Ncurses non-wide-character puisqu'aucun paquet installé par la compilation à partir des sources ne se lie à elles lors de l'exécution. Pour le moment, les seules applications binaires connues qui se lient aux bibliothèques Ncurses non-wide-character exigent la version 5. Si vous devez avoir de telles bibliothèques à cause d'une application disponible uniquement en binaire ou pour vous conformer à la LSB, compilez à nouveau le paquet avec les commandes suivantes :

    #     make distclean
    #     ./configure --prefix=/usr    \
    #                 --with-shared    \
    #                 --without-normal \
    #                 --without-debug  \
    #                 --without-cxx-binding \
    #                 --with-abi-version=5
    #     make sources libs
    #     cp -av lib/lib*.so.5* /usr/lib
popd

rm -rf ncurses-6.4-20230520.tar.xz

#################Sed-4.9##################

tar xvf sed-4.9.tar.xz

pushd sed-4.9
    ./configure --prefix=/usr
    make
    make html
    chown -R tester .
    set +e
    su tester -c "PATH=$PATH make check"
    set -e
    make install
    install -d -m755           /usr/share/doc/sed-4.9
    install -m644 doc/sed.html /usr/share/doc/sed-4.9
popd

rm -rf sed-4.9

#################Psmisc-23.6##################

tar xvf psmisc-23.6.tar.xz

pushd psmisc-23.6
    ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
popd

rm -rf psmisc-23.6

#################Gettext-0.22.4.tar.xz##################

tar xvf gettext-0.22.4.tar.xz

pushd gettext-0.22.4
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.22.4
    make
    run_make_check "make check"

    make install
    chmod -v 0755 /usr/lib/preloadable_libintl.so

popd

rm -rf gettext-0.22.4

#################Bison-3.8.2##################

tar xvf bison-3.8.2.tar.xz

pushd bison-3.8.2
    ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
    make
    run_make_check "make check"
    make install
popd

rm -rf bison-3.8.2

#################Grep-3.11##################

tar xvf grep-3.11.tar.xz

pushd grep-3.11
    sed -i "s/echo/#echo/" src/egrep.sh
    ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
popd

rm -rf grep-3.11

#################Bash-5.2.21##################

tar xvf bash-5.2.21.tar.gz

pushd bash-5.2.21
    patch -Np1 -i ../bash-5.2.21-upstream_fixes-1.patch
    ./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.2.21
    make
    chown -R tester .
    set +e
    su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF
    set -e
    make install
    exec /usr/bin/bash --login
popd

rm -rf bash-5.2.21

#################Libtool-2.4.7.tar.xz##################

tar xvf libtool-2.4.7.tar.xz

pushd libtool-2.4.7
    ./configure --prefix=/usr
    make
    run_make_check "make -k check"
    make install
    rm -fv /usr/lib/libltdl.a
popd

rm -rf libtool-2.4.7

#################Gdbm-1.23.tar.gz##################

tar xvf gdbm-1.23.tar.gz

pushd gdbm-1.23
    ./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
    make
    run_make_check "make -k check"
    make install
popd

rm -rf gdbm-1.23

#################gperf-3.1.tar.gz##################

tar xvf gperf-3.1.tar.gz

pushd gperf-3.1
    ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
    make
    run_make_check "make -k -j1 check"
    make install
popd

rm -rf gperf-3.1

#################Expat-2.6.0##################

tar xvf expat-2.6.0.tar.xz

pushd expat-2.6.0
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.6.0
    make
    run_make_check "make check"
    make install
    install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.0
popd

rm -rf expat-2.6.0

#################Inetutils-2.5##################

tar xvf inetutils-2.5.tar.xz

pushd inetutils-2.5
    ./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
    make
    run_make_check "make check"
    make install
    mv -v /usr/{,s}bin/ifconfig
popd

rm -rf inetutils-2.5

#################less-643.tar.gz##################

tar xvf less-643.tar.gz

pushd less-643
    ./configure --prefix=/usr --sysconfdir=/etc
    make
    run_make_check "make check"
    make install
popd

rm -rf less-643

#################perl-5.38.2.tar.xz##################

tar xvf perl-5.38.2.tar.xz

pushd perl-5.38.2
    export BUILD_ZLIB=False
    export BUILD_BZIP2=0
    sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.38/core_perl      \
             -Darchlib=/usr/lib/perl5/5.38/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.38/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.38/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.38/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.38/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads
    
    make
    set +e
    TEST_JOBS=$(nproc) make test_harness
    set -e
    make install
    unset BUILD_ZLIB BUILD_BZIP2
popd

rm -rf perl-5.38.2

#################XML::Parser-2.47##################

tar xvf XML-Parser-2.47.tar.gz

pushd XML-Parser-2.47
    perl Makefile.PL
    make
    run_make_check "make test"
    make install
popd

rm -rf XML-Parser-2.47

#################intltool-0.51.0.tar.gz##################

tar xvf intltool-0.51.0.tar.gz

pushd intltool-0.51.0
    sed -i 's:\\\${:\\\$\\{:' intltool-update.in
    ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
    install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
popd

rm -rf intltool-0.51.0

#################autoconf-2.72.tar.xz##################

tar xvf autoconf-2.72.tar.xz

pushd autoconf-2.72
    ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
popd

rm -rf autoconf-2.72

#################OpenSSL-3.2.1##################

tar xvf openssl-3.2.1.tar.gz

pushd openssl-3.2.1
    ./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
    make
    set +e
    HARNESS_JOBS=$(nproc) make test
    set -e
    sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
    make MANSUFFIX=ssl install
    mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.2.1
    cp -vfr doc/* /usr/share/doc/openssl-3.2.1
popd

rm -rf openssl-3.2.1

#################Kmod-31 ##################

tar xvf  kmod-31.tar.xz

pushd kmod-31
    ./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --with-openssl         \
            --with-xz              \
            --with-zstd            \
            --with-zlib
    make
    make install

    for target in depmod insmod modinfo modprobe rmmod; do
    ln -sfv ../bin/kmod /usr/sbin/$target
    done

    ln -sfv kmod /usr/bin/lsmod
popd

rm -rf kmod-31

#################Libelf Elfutils-3.10 ##################

tar xvf elfutils-0.190.tar.bz2

pushd elfutils-0.190
    ./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy
    make
    run_make_check "make check"
    make -C libelf install
    install -vm644 config/libelf.pc /usr/lib/pkgconfig
    rm /usr/lib/libelf.a
popd

rm -rf elfutils-0.190

#################libffi-3.4.4.tar.gz##################

tar xvf libffi-3.4.4.tar.gz

pushd libffi-3.4.4
    ./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native
    make
    run_make_check "make check"
    make install
popd

rm -rf libffi-3.4.4

#################Python-3.12.2.tar.xz##################

tar xvf Python-3.12.2.tar.xz

pushd Python-3.12.2
    ./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --enable-optimizations
    make
    make install
    cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF
popd

rm -rf Python-3.12.2

#################flit_core-3.9.0.tar.gz###################

tar xvf flit_core-3.9.0.tar.gz

pushd flit_core-3.9.0
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --no-user --find-links dist flit_core

popd

rm -rf flit_core-3.9.0

#################Wheel-0.42.0##################

tar xvf wheel-0.42.0.tar.gz

pushd wheel-0.42.0
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --find-links=dist wheel
popd

rm -rf wheel-0.42.0

#################setuptools-69.1.0.tar.gz##################

tar xvf setuptools-69.1.0.tar.gz

pushd setuptools-69.1.0
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --find-links dist setuptools
popd

rm -rf setuptools-69.1.0

#################Ninja-1.11.1##################

tar xvf ninja-1.11.1.tar.gz

pushd ninja-1.11.1
    export NINJAJOBS=4
    sed -i '/int Guess/a \
        int   j = 0;\
        char* jobs = getenv( "NINJAJOBS" );\
        if ( jobs != NULL ) j = atoi( jobs );\
        if ( j > 0 ) return j;\
        ' src/ninja.cc
    python3 configure.py --bootstrap

    install -vm755 ninja /usr/bin/
    install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
    install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

popd

rm -rf ninja-1.11.1

#################meson-1.3.2.tar.gz##################

tar xvf meson-1.3.2.tar.gz

pushd meson-1.3.2
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --find-links dist meson
    install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
    install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
popd

rm -rf meson-1.3.2

#################Coreutils-9.4##################

tar xvf coreutils-9.4.tar.xz

pushd coreutils-9.4
    patch -Np1 -i ../coreutils-9.4-i18n-1.patch
    sed -e '/n_out += n_hold/,+4 s|.*bufsize.*|//&|' -i src/split.c
    autoreconf -fiv
    CE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
    make
    make NON_ROOT_USERNAME=tester check-root
    groupadd -g 102 dummy -U tester
    chown -R tester .
    set +e
    su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
    set -e
    groupdel dummy
    make install
    mv -v /usr/bin/chroot /usr/sbin
    mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
popd

rm -rf coreutils-9.4

#################Check-0.15.2##################

tar xvf check-0.15.2.tar.gz

pushd check-0.15.2
    ./configure --prefix=/usr --disable-static
    make
    run_make_check "make check"
    make docdir=/usr/share/doc/check-0.15.2 install
popd

rm -rf check-0.15.2

#################diffutils-3.10.tar.xz##################

tar xvf diffutils-3.10.tar.xz

pushd diffutils-3.10
    ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
popd

rm -rf diffutils-3.10

#################Gawk-5.3.0 ##################

tar xvf gawk-5.3.0.tar.xz

pushd  gawk-5.3.0
    sed -i 's/extras//' Makefile.in
    ./configure --prefix=/usr
    make 
    set +e
    chown -R tester .
    su tester -c "PATH=$PATH make check"
    set -e
    rm -f /usr/bin/gawk-5.3.0
    make install
    ln -sv gawk.1 /usr/share/man/man1/awk.1
    mkdir -pv /usr/share/doc/gawk-5.3.0
    cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.3.0
popd

rm -rf gawk-5.3.0

#################findutils-4.9.0.tar.xz##################

tar xvf findutils-4.9.0.tar.xz

pushd findutils-4.9.0
    ./configure --prefix=/usr --localstatedir=/var/lib/locate
    make 
    set +e
    chown -R tester .
    su tester -c "PATH=$PATH make check"
    set -e
    make install
popd

rm -rf findutils-4.9.0

#################Groff-1.23.0 ##################

tar xvf groff-1.23.0.tar.gz

pushd groff-1.23.0
    PAGE=<taille_papier> ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
popd

rm -rf groff-1.23.0

#################GRUB-2.12##################

tar xvf grub-2.12.tar.xz

pushd grub-2.12
    unset {C,CPP,CXX,LD}FLAGS
    echo depends bli part_gpt > grub-core/extra_deps.lst
    ./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror
    make
    make install
    mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
popd

rm -rf grub-2.12

#################Gzip-1.13##################

tar xvf gzip-1.13.tar.xz

pushd gzip-1.13
    ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
popd

rm -rf gzip-1.13

#################IPRoute2-6.7.0##################

tar xvf iproute2-6.7.0.tar.xz

pushd iproute2-6.7.0
    sed -i /ARPD/d Makefile
    rm -fv man/man8/arpd.8
    make NETNS_RUN_DIR=/run/netns
    make SBINDIR=/usr/sbin install
    mkdir -pv /usr/share/doc/iproute2-6.7.0
    cp -v COPYING README* /usr/share/doc/iproute2-6.7.0
popd

rm -rf iproute2-6.7.0

#################kbd-2.6.4.tar.xz##################

tar xvf kbd-2.6.4.tar.xz

pushd kbd-2.6.4
    patch -Np1 -i ../kbd-2.6.4-backspace-1.patch
    sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
    ./configure --prefix=/usr --disable-vlock
    make
    run_make_check "make check"
    make install
popd

rm -rf kbd-2.6.4

#################Libpipeline-1.5.7##################

tar xvf libpipeline-1.5.7.tar.gz

pushd libpipeline-1.5.7
    ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
popd

rm -rf libpipeline-1.5.7

#################Make-4.4.1 ##################

tar xvf make-4.4.1.tar.gz

pushd make-4.4.1
    ./configure --prefix=/usr
    make
    set +e
    chown -R tester .
    su tester -c "PATH=$PATH make check"
    set -e
    make install
popd

rm -rf make-4.4.1

#################Patch-2.7.6##################

tar xvf patch-2.7.6.tar.xz

pushd patch-2.7.6
    ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
popd

rm -rf patch-2.7.6

#################Tar-1.35 ##################

tar xvf tar-1.35.tar.xz

pushd tar-1.35
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
    make -C doc install-html docdir=/usr/share/doc/tar-1.35
popd

rm -rf tar-1.35

#################Texinfo-7.1 ##################

tar xvf texinfo-7.1.tar.xz

pushd texinfo-7.1
    ./configure --prefix=/usr
    make
    run_make_check "make check"
    make install
    make TEXMF=/usr/share/texmf install-tex
    pushd /usr/share/info
        rm -v dir
        for f in *
            do install-info $f dir 2>/dev/null
        done
    popd
popd    

rm -rf texinfo-7.1

#################Vim-9.1.0041 ##################

tar xvf vim-9.1.0041.tar.gz

pushd vim-9.1.0041
    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
    ./configure --prefix=/usr
    make
    set +e
    chown -R tester .
    su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" &> vim-test.log
    set -e
    make install
    ln -sv vim /usr/bin/vi
    for L in  /usr/share/man/{,*/}man1/vim.1; do
        ln -sv vim.1 $(dirname $L)/vi.1
    done
    ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.0041
    cat > /etc/vimrc << "EOF"
" Début de /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" Fin de /etc/vimrc
EOF
popd

rm -rf vim-9.1.0041

#################MarkupSafe-2.1.5##################

tar xvf MarkupSafe-2.1.5.tar.gz

pushd MarkupSafe-2.1.5
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --no-user --find-links dist Markupsafe
popd

rm -rf MarkupSafe-2.1.5

#################Jinja2-3.1.3.tar.gz##################

tar xvf Jinja2-3.1.3.tar.gz

pushd Jinja2-3.1.3
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --no-user --find-links dist Jinja2
popd

rm -rf Jinja2-3.1.3

#################Systemd-255##################

tar xvf systemd-255.tar.gz

pushd systemd-255
    sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in
    patch -Np1 -i ../systemd-255-upstream_fixes-1.patch
    mkdir -p build
    pushd build
        meson setup \
            --prefix=/usr                 \
            --buildtype=release           \
            -Ddefault-dnssec=no           \
            -Dfirstboot=false             \
            -Dinstall-tests=false         \
            -Dldconfig=false              \
            -Dsysusers=false              \
            -Drpmmacrosdir=no             \
            -Dhomed=disabled              \
            -Duserdb=false                \
            -Dman=disabled                \
            -Dmode=release                \
            -Dpamconfdir=no               \
            -Ddev-kvm-mode=0660           \
            -Dnobody-group=nogroup        \
            -Dsysupdate=disabled          \
            -Dukify=disabled              \
            -Ddocdir=/usr/share/doc/systemd-255 \
            ..
        ninja
        ninja install
        tar -xf ../../systemd-man-pages-255.tar.xz \
            --no-same-owner --strip-components=1   \
            -C /usr/share/man
        systemd-machine-id-setup
        systemctl preset-all
    popd
popd

rm -rf systemd-255

#################dbus-1.14.10.tar.xz##################

tar xvf dbus-1.14.10.tar.xz

pushd dbus-1.14.10
    ./configure --prefix=/usr                        \
            --sysconfdir=/etc                    \
            --localstatedir=/var                 \
            --runstatedir=/run                   \
            --enable-user-session                \
            --disable-static                     \
            --disable-doxygen-docs               \
            --disable-xml-docs                   \
            --docdir=/usr/share/doc/dbus-1.14.10 \
            --with-system-socket=/run/dbus/system_bus_socket
    make
    run_make_check "make check"
    make install
    ln -sv /etc/machine-id /var/lib/dbus
popd

rm -rf dbus-1.14.10

#################man-db-2.12.0.tar.xz##################

tar xvf man-db-2.12.0.tar.xz

pushd man-db-2.12.0
    ./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.12.0 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap
    make
    run_make_check "make check"
    make install
popd

rm -rf man-db-2.12.0

#################procps-ng-4.0.4.tar.xz##################

tar xvf procps-ng-4.0.4.tar.xz

pushd procps-ng-4.0.4
    ./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.4 \
            --disable-static                        \
            --disable-kill                          \
            --with-systemd
    make src_w_LDADD='$(LDADD) -lsystemd'
    run_make_check "make -k check"
    make install
popd

rm -rf procps-ng-4.0.4

#################Util-linux-2.39.3##################

tar xvf util-linux-2.39.3.tar.xz

pushd util-linux-2.39.3
    sed -i '/test_mkfds/s/^/#/' tests/helpers/Makemodule.am
    ./configure --bindir=/usr/bin    \
            --libdir=/usr/lib    \
            --runstatedir=/run   \
            --sbindir=/usr/sbin  \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.39.3
    make
    set +e
    chown -R tester .
    su tester -c "make -k check"
    set -e
    make install
popd

rm -rf util-linux-2.39.3

#################E2fsprogs-1.47.0##################

tar xvf e2fsprogs-1.47.0.tar.gz

pushd e2fsprogs-1.47.0
    mkdir -v build
    pushd build
        ../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
        make
        run_make_check "make check"
        make install
        rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
        gunzip -v /usr/share/info/libext2fs.info.gz
        install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
        sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf
    popd
popd

rm -rf e2fsprogs-1.47.0
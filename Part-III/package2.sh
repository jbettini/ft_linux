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


##############Libtool-2.4.7.tar.xz##################

tar xvf libtool-2.4.7.tar.xz

pushd libtool-2.4.7
    ./configure --prefix=/usr
    make
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
    make install
popd

rm -rf gdbm-1.23

#################gperf-3.1.tar.gz##################

tar xvf gperf-3.1.tar.gz

pushd gperf-3.1
    ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
    make
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
    make install
    install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.0
popd

rm -rf expat-2.6.0

###############Inetutils-2.5##################

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
    make install
    mv -v /usr/{,s}bin/ifconfig
popd

rm -rf inetutils-2.5

#################less-643.tar.gz##################

tar xvf less-643.tar.gz

pushd less-643
    ./configure --prefix=/usr --sysconfdir=/etc
    make
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
    make install
    unset BUILD_ZLIB BUILD_BZIP2
popd

rm -rf perl-5.38.2

################XML::Parser-2.47##################

tar xvf XML-Parser-2.47.tar.gz

pushd XML-Parser-2.47
    perl Makefile.PL
    make
    make install
popd

rm -rf XML-Parser-2.47

#################intltool-0.51.0.tar.gz##################

tar xvf intltool-0.51.0.tar.gz

pushd intltool-0.51.0
    sed -i 's:\\\${:\\\$\\{:' intltool-update.in
    ./configure --prefix=/usr
    make
    make install
    install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
popd

rm -rf intltool-0.51.0

#################autoconf-2.72.tar.xz##################

tar xvf autoconf-2.72.tar.xz

pushd autoconf-2.72
    ./configure --prefix=/usr
    make
    make install
popd

rm -rf autoconf-2.72

#################automake-1.16.5.tar.xz##################

tar xvf automake-1.16.5.tar.xz

pushd automake-1.16.5
    ./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5
    make
    make install
popd

rm -rf automake-1.16.5

#################OpenSSL-3.2.1##################

tar xvf openssl-3.2.1.tar.gz

pushd openssl-3.2.1
    ./config --prefix=/usr     \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
    make
    sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
    make MANSUFFIX=ssl install
    mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.2.1
    cp -vfr doc/* /usr/share/doc/openssl-3.2.1
popd

rm -rf openssl-3.2.1

###############Kmod-31 ##################

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

################Libelf Elfutils-3.10 ##################

tar xvf elfutils-0.190.tar.bz2

pushd elfutils-0.190
    ./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy
    make
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

##############Coreutils-9.4##################

tar xvf coreutils-9.4.tar.xz

pushd coreutils-9.4
    # patch -Np1 -i ../coreutils-9.4-i18n-1.patch
    # sed -e '/n_out += n_hold/,+4 s|.*bufsize.*|//&|' -i src/split.c
    # autoreconf -fiv
    FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
    make
    make install
    mv -v /usr/bin/chroot /usr/sbin
    mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
popd

rm -rf coreutils-9.4

################Check-0.15.2##################

tar xvf check-0.15.2.tar.gz

pushd check-0.15.2
    ./configure --prefix=/usr --disable-static
    make
    make docdir=/usr/share/doc/check-0.15.2 install
popd

rm -rf check-0.15.2

#################diffutils-3.10.tar.xz##################

tar xvf diffutils-3.10.tar.xz

pushd diffutils-3.10
    ./configure --prefix=/usr
    make
    make install
popd

rm -rf diffutils-3.10

################Gawk-5.3.0 ##################

tar xvf gawk-5.3.0.tar.xz

pushd  gawk-5.3.0
    sed -i 's/extras//' Makefile.in
    ./configure --prefix=/usr
    make 
    rm -f /usr/bin/gawk-5.3.0
    make install
    ln -sv gawk.1 /usr/share/man/man1/awk.1
popd

rm -rf gawk-5.3.0

################findutils-4.9.0.tar.xz##################

tar xvf findutils-4.9.0.tar.xz

pushd findutils-4.9.0
    ./configure --prefix=/usr --localstatedir=/var/lib/locate
    make 
    make install
popd

rm -rf findutils-4.9.0

#################Groff-1.23.0 ##################

tar xvf groff-1.23.0.tar.gz

pushd groff-1.23.0
    ./configure --prefix=/usr
    make
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
    make install
popd

rm -rf kbd-2.6.4

################Libpipeline-1.5.7##################

tar xvf libpipeline-1.5.7.tar.gz

pushd libpipeline-1.5.7
    ./configure --prefix=/usr
    make
    make install
popd

rm -rf libpipeline-1.5.7

#################Make-4.4.1 ##################

tar xvf make-4.4.1.tar.gz

pushd make-4.4.1
    ./configure --prefix=/usr
    make
    make install
popd

rm -rf make-4.4.1

#################Patch-2.7.6##################

tar xvf patch-2.7.6.tar.xz

pushd patch-2.7.6
    ./configure --prefix=/usr
    make
    make install
popd

rm -rf patch-2.7.6

#################Tar-1.35 ##################

tar xvf tar-1.35.tar.xz

pushd tar-1.35
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
    make
    make install
    make -C doc install-html docdir=/usr/share/doc/tar-1.35
popd

rm -rf tar-1.35

#################Texinfo-7.1 ##################

tar xvf texinfo-7.1.tar.xz

pushd texinfo-7.1
    ./configure --prefix=/usr
    make
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
    make install
popd

rm -rf util-linux-2.39.3

#################E2fsprogs-1.47.0##################

tar xvf e2fsprogs-1.47.0.tar.gz

pushd e2fsprogs-1.47.0
    mkdir -pv build
    pushd build
        ../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
        make
        make install
        rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
        gunzip -v /usr/share/info/libext2fs.info.gz
        install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
        sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf
    popd
popd

rm -rf e2fsprogs-1.47.0



print_color "$TXT_GREEN" "Every Package is installed :)"
print_color "$TXT_YELLOW" "Doing a backup is highly recommended here"
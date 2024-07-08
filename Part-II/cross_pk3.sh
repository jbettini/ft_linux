#!/bin/bash

set -eu

handle_error() {
    echo "Error: line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

cd /sources

##################Gettext-0.22.4##################

tar xvf gettext-0.22.4.tar.xz

pushd gettext-0.22.4
    ./configure --disable-shared
    make
    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
popd

rm -rf gettext-0.22.4

##################Bison-3.8.2##################

tar xvf bison-3.8.2.tar.xz

pushd bison-3.8.2
    ./configure --prefix=/usr \
                --docdir=/usr/share/doc/bison-3.8.2
    make
    make install
popd

rm -rf bison-3.8.2

##################Perl-5.38.2##################

tar xvf perl-5.38.2.tar.xz

pushd perl-5.38.2
    sh Configure -des                                        \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Duseshrplib                                \
             -Dprivlib=/usr/lib/perl5/5.38/core_perl     \
             -Darchlib=/usr/lib/perl5/5.38/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.38/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.38/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.38/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.38/vendor_perl
    make
    make install
popd

rm -rf perl-5.38.2

##################Python-3.12.2##################

tar xvf Python-3.12.2.tar.xz

pushd Python-3.12.2
    ./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip
    make
    make install
popd

rm -rf Python-3.12.2

##################Texinfo-7.1##################

tar xvf texinfo-7.1.tar.xz

pushd texinfo-7.1 
    ./configure --prefix=/usr
    make 
    make install
popd

rm -rf texinfo-7.1

##################Util-linux-2.39.3##################

tar xvf util-linux-2.39.3.tar.xz

pushd util-linux-2.39.3 
    mkdir -pv /var/lib/hwclock
    ./configure --libdir=/usr/lib    \
            --runstatedir=/run   \
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

##################Cleaning##################

rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools
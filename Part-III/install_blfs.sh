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

cd /sources/_BLFS

load_bootscript () {
    cp ../blfs-bootscripts-20240209.tar.xz .
    tar xvf blfs-bootscripts-20240209.tar.xz
    pushd blfs-bootscripts-20240209
        $1
    popd 
}

load_systemd_unit () {
    cp ../blfs-systemd-units-20240205.tar.xz .
    tar xvf blfs-systemd-units-20240205.tar.xz
    pushd blfs-systemd-units-20240205
        $1
    popd 
}

################net-tools-2.10.tar.xz#################
tar xvf net-tools-2.10.tar.xz

pushd net-tools-2.10
    export BINDIR='/usr/bin' SBINDIR='/usr/bin' &&
    yes "" | make -j1                           &&
    make DESTDIR=$PWD/install -j1 install       &&
    rm    install/usr/bin/{nis,yp}domainname    &&
    rm    install/usr/bin/{hostname,dnsdomainname,domainname,ifconfig} &&
    rm -r install/usr/share/man/man1            &&
    rm    install/usr/share/man/man8/ifconfig.8 &&
    unset BINDIR SBINDIR
    chown -R root:root install &&
    cp -a install/* /
popd

rm -rf net-tools-2.10

################libtasn1-4.19.0#################
tar xvf libtasn1-4.19.0.tar.gz

pushd libtasn1-4.19.0
    ./configure --prefix=/usr --disable-static &&
    make
    make install
    make -C doc/reference install-data-local
popd

rm -rf libtasn1-4.19.0

################p11-kit-0.25.3#################
tar xvf p11-kit-0.25.3.tar.xz

pushd p11-kit-0.25.3
    sed '20,$ d' -i trust/trust-extract-compat &&

cat >> trust/trust-extract-compat << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Update trust stores
/usr/sbin/make-ca -r
EOF
    mkdir p11-build &&
    cd    p11-build &&

    meson setup ..            \
        --prefix=/usr       \
        --buildtype=release \
        -Dtrust_paths=/etc/pki/anchors &&
    ninja
    ninja install &&
    ln -sfv /usr/libexec/p11-kit/trust-extract-compat \
            /usr/bin/update-ca-certificates
    ln -sfv ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so
popd

rm -rf p11-kit-0.25.3

################nspr-4.35#################
tar xvf nspr-4.35.tar.gz

pushd nspr-4.35
    cd nspr &&
    sed -i '/^RELEASE/s|^|#|' pr/src/misc/Makefile.in &&
    sed -i 's|$(LIBRARY) ||'  config/rules.mk         &&

    ./configure --prefix=/usr   \
                --with-mozilla  \
                --with-pthreads \
                $([ $(uname -m) = x86_64 ] && echo --enable-64bit) &&
    make
    make install
popd

rm -rf nspr-4.35

################SQLite#################
tar xvf sqlite-autoconf-3450100.tar.gz

pushd sqlite-autoconf-3450100
    ./configure --prefix=/usr     \
            --disable-static  \
            --enable-fts{4,5} \
            CPPFLAGS="-DSQLITE_ENABLE_COLUMN_METADATA=1 \
                      -DSQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                      -DSQLITE_ENABLE_DBSTAT_VTAB=1     \
                      -DSQLITE_SECURE_DELETE=1          \
                      -DSQLITE_ENABLE_FTS3_TOKENIZER=1" &&
    make
    make install
popd

rm -rf sqlite-autoconf-3450100

################nss-3.98.tar.gz#################
tar xvf nss-3.98.tar.gz

pushd nss-3.98
    patch -Np1 -i ../nss-3.98-standalone-1.patch &&

    cd nss &&

    make BUILD_OPT=1                      \
    NSPR_INCLUDE_DIR=/usr/include/nspr  \
    USE_SYSTEM_ZLIB=1                   \
    ZLIB_LIBS=-lz                       \
    NSS_ENABLE_WERROR=0                 \
    $([ $(uname -m) = x86_64 ] && echo USE_64=1) \
    $([ -f /usr/include/sqlite3.h ] && echo NSS_USE_SYSTEM_SQLITE=1)

    cd ../dist                                                          &&
    install -v -m755 Linux*/lib/*.so              /usr/lib              &&
    install -v -m644 Linux*/lib/{*.chk,libcrmf.a} /usr/lib              &&
    install -v -m755 -d                           /usr/include/nss      &&
    cp -v -RL {public,private}/nss/*              /usr/include/nss      &&
    install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} /usr/bin &&
    install -v -m644 Linux*/lib/pkgconfig/nss.pc  /usr/lib/pkgconfig

    ln -sfv ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so
popd

rm -rf nss-3.98

################make-ca-1.13#################
tar xvf make-ca-1.13.tar.xz

pushd make-ca-1.13
    make install &&
    install -vdm755 /etc/ssl/local
    systemctl enable update-pki.timer
popd

rm -rf make-ca-1.13

################libunistring-1.1#################
tar xvf libunistring-1.1.tar.xz

pushd libunistring-1.1
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libunistring-1.1 &&
    make
    make install
popd

rm -rf libunistring-1.1

################libidn2-2.3.7#################
tar xvf libidn2-2.3.7.tar.gz

pushd libidn2-2.3.7
    ./configure --prefix=/usr --disable-static &&
    make
    make install
popd

rm -rf libidn2-2.3.7

################libpsl-0.21.5#################
tar xvf libpsl-0.21.5.tar.gz

pushd libpsl-0.21.5
    mkdir build &&
    cd    build &&

    meson setup --prefix=/usr --buildtype=release &&

    ninja
    ninja install
popd

rm -rf libpsl-0.21.5

################pcre2-10.42.tar.bz2#################
tar xvf pcre2-10.42.tar.bz2

pushd pcre2-10.42
    ./configure --prefix=/usr                       \
                --docdir=/usr/share/doc/pcre2-10.42 \
                --enable-unicode                    \
                --enable-jit                        \
                --enable-pcre2-16                   \
                --enable-pcre2-32                   \
                --enable-pcre2grep-libz             \
                --enable-pcre2grep-libbz2           \
                --enable-pcre2test-libreadline      \
                --disable-static                    &&
    make
    make install
popd

rm -rf pcre2-10.42

################nettle-3.9.1.tar.gz#################
tar xvf nettle-3.9.1.tar.gz

pushd nettle-3.9.1
    ./configure --prefix=/usr --disable-static &&
    make
    make install &&
    chmod   -v   755 /usr/lib/lib{hogweed,nettle}.so &&
    install -v -m755 -d /usr/share/doc/nettle-3.9.1 &&
    install -v -m644 nettle.{html,pdf} /usr/share/doc/nettle-3.9.1
popd

rm -rf nettle-3.9.1

################gnutls-3.8.3.tar.xz#################
tar xvf gnutls-3.8.3.tar.xz

pushd gnutls-3.8.3
    ./configure --prefix=/usr \
            --docdir=/usr/share/doc/gnutls-3.8.3 \
            --with-default-trust-store-pkcs11="pkcs11:" &&
    make
    make install
popd

rm -rf gnutls-3.8.3

################wget-1.21.4.tar.gz#################
tar xvf wget-1.21.4.tar.gz

pushd wget-1.21.4
    ./configure --prefix=/usr      \
                --sysconfdir=/etc  \
                --with-ssl=openssl &&
    make
    make install
popd

rm -rf wget-1.21.4

################curl-8.6.0.tar.xz#################
tar xvf curl-8.6.0.tar.xz

pushd curl-8.6.0
    ./configure --prefix=/usr                           \
            --disable-static                        \
            --with-openssl                          \
            --enable-threaded-resolver              \
            --with-ca-path=/etc/ssl/certs &&
    make
    make install &&

    rm -rf docs/examples/.deps &&

    find docs \( -name Makefile\* -o  \
                -name \*.1       -o  \
                -name \*.3       -o  \
                -name CMakeLists.txt \) -delete &&

    cp -v -R docs -T /usr/share/doc/curl-8.6.0
popd

rm -rf curl-8.6.0

################six-1.16.0.tar.gz#################
tar xvf six-1.16.0.tar.gz

pushd six-1.16.0
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links=dist --no-cache-dir --no-user six
popd

rm -rf six-1.16.0

################gdb-14.1.tar.xz#################
tar xvf gdb-14.1.tar.xz

pushd gdb-14.1
    mkdir build &&
    cd    build &&

    ../configure --prefix=/usr          \
                --with-system-readline \
                --with-python=/usr/bin/python3 &&
    make
    make -C gdb install &&
    make -C gdbserver install
popd

rm -rf gdb-14.1

################ Linux-PAM-1.6.0 ################
tar xvf Linux-PAM-1.6.0.tar.xz

pushd 
    ./configure --prefix=/usr                        \
                --sbindir=/usr/sbin                  \
                --sysconfdir=/etc                    \
                --libdir=/usr/lib                    \
                --enable-securedir=/usr/lib/security \
                --docdir=/usr/share/doc/Linux-PAM-1.6.0 &&
    make
    install -v -m755 -d /etc/pam.d &&

cat > /etc/pam.d/other << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF
    rm -fv /etc/pam.d/other
    make install &&
    chmod -v 4755 /usr/sbin/unix_chkpwd
popd

rm -rf 


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

cat > /etc/systemd/network/enp0s2.network << EOF
[Match]
Name=enp0s2

[Network]
DHCP=yes

[DHCPv4]
UseDomains=true
EOF

systemctl enable systemd-networkd
systemctl enable systemd-resolved

ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

systemctl start systemd-networkd
systemctl start systemd-resolved

systemctl daemon-reload

systemctl restart systemd-networkd
systemctl restart systemd-resolved

################ openssh-9.6p1.tar.gz################
tar xvf openssh-9.6p1.tar.gz

pushd openssh-9.6p1
    install -v -g sys -m700 -d /var/lib/sshd &&
    groupadd -g 50 sshd        &&
    useradd  -c 'sshd PrivSep' \
            -d /var/lib/sshd  \
            -g sshd           \
            -s /bin/false     \
            -u 50 sshd
    ./configure --prefix=/usr                            \
            --sysconfdir=/etc/ssh                    \
            --with-privsep-path=/var/lib/sshd        \
            --with-default-path=/usr/bin             \
            --with-superuser-path=/usr/sbin:/usr/bin \
            --with-pid-dir=/run                      &&
    make
    make install &&
    install -v -m755    contrib/ssh-copy-id /usr/bin     &&

    install -v -m644    contrib/ssh-copy-id.1 \
                        /usr/share/man/man1              &&
    install -v -m755 -d /usr/share/doc/openssh-9.6p1     &&
    install -v -m644    INSTALL LICENCE OVERVIEW README* \
                        /usr/share/doc/openssh-9.6p1
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    echo " Port 22" >> /etc/ssh/sshd_config
   
    load_systemd_unit "make install-sshd"
    systemctl enable sshd
    systemctl start sshd
    systemctl daemon-reload
    systemctl restart sshd
popd

rm -rf openssh-9.6p1

################LMDB_0.9.31.tar.gz#################
tar xvf LMDB_0.9.31.tar.gz

pushd LMDB_0.9.31
    cd libraries/liblmdb &&
    make                 &&
    sed -i 's| liblmdb.a||' Makefile
    make prefix=/usr install
popd

rm -rf LMDB_0.9.31

################cyrus-sasl-2.1.28.tar.gz#################
tar xvf cyrus-sasl-2.1.28.tar.gz

pushd cyrus-sasl-2.1.28
    ./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --enable-auth-sasldb \
            --with-dblib=lmdb    \
            --with-dbpath=/var/lib/sasl/sasldb2 \
            --with-sphinx-build=no              \
            --with-saslauthd=/var/run/saslauthd &&
    make -j1
    make install &&
    install -v -dm755                          /usr/share/doc/cyrus-sasl-2.1.28/html &&
    install -v -m644  saslauthd/LDAP_SASLAUTHD /usr/share/doc/cyrus-sasl-2.1.28      &&
    install -v -m644  doc/legacy/*.html        /usr/share/doc/cyrus-sasl-2.1.28/html &&
    install -v -dm700 /var/lib/sasl
    load_systemd_unit "make install-saslauthd"
popd

rm -rf cyrus-sasl-2.1.28

################OpenLDAP-2.6.7 #################
tar xvf openldap-2.6.7.tgz

pushd openldap-2.6.7
    groupadd -g 83 ldap &&
    useradd  -c "OpenLDAP Daemon Owner" \
            -d /var/lib/openldap -u 83 \
            -g ldap -s /bin/false ldap
    patch -Np1 -i ../openldap-2.6.7-consolidated-1.patch && 
    autoconf &&
    ./configure --prefix=/usr         \
                --sysconfdir=/etc     \
                --localstatedir=/var  \
                --libexecdir=/usr/lib \
                --disable-static      \
                --disable-debug       \
                --with-tls=openssl    \
                --with-cyrus-sasl     \
                --without-systemd     \
                --enable-dynamic      \
                --enable-crypt        \
                --enable-spasswd      \
                --enable-slapd        \
                --enable-modules      \
                --enable-rlookups     \
                --enable-backends=mod \
                --disable-sql         \
                --disable-wt          \
                --enable-overlays=mod &&

    make depend &&
    make
    make install &&

    sed -e "s/\.la/.so/" -i /etc/openldap/slapd.{conf,ldif}{,.default} &&

    install -v -dm700 -o ldap -g ldap /var/lib/openldap     &&

    install -v -dm700 -o ldap -g ldap /etc/openldap/slapd.d &&
    chmod   -v    640     /etc/openldap/slapd.{conf,ldif}   &&
    chown   -v  root:ldap /etc/openldap/slapd.{conf,ldif}   &&

    install -v -dm755 /usr/share/doc/openldap-2.6.7 &&
    cp      -vfr      doc/{drafts,rfc,guide} \
                    /usr/share/doc/openldap-2.6.7
    load_systemd_unit "make install-slapd"
popd

rm -rf openldap-2.6.7

#################npth-1.6.tar.bz2################
tar xvf npth-1.6.tar.bz2

pushd npth-1.6
    ./configure --prefix=/usr &&
    make
    make install
popd

rm -rf npth-1.6

################libgpg-error-1.47.tar.bz2#################
tar xvf libgpg-error-1.47.tar.bz2

pushd libgpg-error-1.47
    ./configure --prefix=/usr &&
    make
    make install &&
    install -v -m644 -D README /usr/share/doc/libgpg-error-1.47/README
popd

rm -rf libgpg-error-1.47

################libksba-1.6.5.tar.bz2#################
tar xvf libksba-1.6.5.tar.bz2

pushd libksba-1.6.5
    ./configure --prefix=/usr &&
    make
    make install
popd

rm -rf libksba-1.6.5

################libgcrypt-1.10.3.tar.bz2#################
tar xvf libgcrypt-1.10.3.tar.bz2

pushd libgcrypt-1.10.3
    ./configure --prefix=/usr &&
    make                      &&

    make -C doc html                                                       &&
    makeinfo --html --no-split -o doc/gcrypt_nochunks.html doc/gcrypt.texi &&
    makeinfo --plaintext       -o doc/gcrypt.txt           doc/gcrypt.texi
    make install &&
    install -v -dm755   /usr/share/doc/libgcrypt-1.10.3 &&
    install -v -m644    README doc/{README.apichanges,fips*,libgcrypt*} \
                        /usr/share/doc/libgcrypt-1.10.3 &&

    install -v -dm755   /usr/share/doc/libgcrypt-1.10.3/html &&
    install -v -m644 doc/gcrypt.html/* \
                        /usr/share/doc/libgcrypt-1.10.3/html &&
    install -v -m644 doc/gcrypt_nochunks.html \
                        /usr/share/doc/libgcrypt-1.10.3      &&
    install -v -m644 doc/gcrypt.{txt,texi} \
                        /usr/share/doc/libgcrypt-1.10.3
popd

rm -rf libgcrypt-1.10.3

################libassuan-2.5.6.tar.bz2#################
tar xvf libassuan-2.5.6.tar.bz2

pushd libassuan-2.5.6
    ./configure --prefix=/usr &&
    make                      &&

    make -C doc html                                                       &&
    makeinfo --html --no-split -o doc/assuan_nochunks.html doc/assuan.texi &&
    makeinfo --plaintext       -o doc/assuan.txt           doc/assuan.texi
    make -C doc pdf ps
    make install &&

    install -v -dm755   /usr/share/doc/libassuan-2.5.6/html &&
    install -v -m644 doc/assuan.html/* \
                        /usr/share/doc/libassuan-2.5.6/html &&
    install -v -m644 doc/assuan_nochunks.html \
                        /usr/share/doc/libassuan-2.5.6      &&
    install -v -m644 doc/assuan.{txt,texi} \
                        /usr/share/doc/libassuan-2.5.6
    install -v -m644  doc/assuan.{pdf,ps,dvi} \
                    /usr/share/doc/libassuan-2.5.6
popd

rm -rf libassuan-2.5.6

################pinentry-1.2.1.tar.bz2#################
tar xvf pinentry-1.2.1.tar.bz2

pushd pinentry-1.2.1
    ./configure --prefix=/usr --enable-pinentry-tty &&
    make
    make install
popd

rm -rf pinentry-1.2.1

################gnupg-2.4.4.tar.bz2#################
tar xvf gnupg-2.4.4.tar.bz2

pushd gnupg-2.4.4
    mkdir build &&
    cd    build &&

    ../configure --prefix=/usr           \
                --localstatedir=/var    \
                --sysconfdir=/etc       \
                --docdir=/usr/share/doc/gnupg-2.4.4 &&
    make &&

    makeinfo --html --no-split -I doc -o doc/gnupg_nochunks.html ../doc/gnupg.texi &&
    makeinfo --plaintext       -I doc -o doc/gnupg.txt           ../doc/gnupg.texi &&
    make -C doc html
    make install &&

    install -v -m755 -d /usr/share/doc/gnupg-2.4.4/html            &&
    install -v -m644    doc/gnupg_nochunks.html \
                        /usr/share/doc/gnupg-2.4.4/html/gnupg.html &&
    install -v -m644    ../doc/*.texi doc/gnupg.txt \
                        /usr/share/doc/gnupg-2.4.4 &&
    install -v -m644    doc/gnupg.html/* \
                        /usr/share/doc/gnupg-2.4.4/html
popd

rm -rf gnupg-2.4.4

################git-2.44.0.tar.xz#################
tar xvf git-2.44.0.tar.xz

pushd git-2.44.0
    ./configure --prefix=/usr \
                --with-gitconfig=/etc/gitconfig \
                --with-python=python3 &&
    make
    make perllibdir=/usr/lib/perl5/5.38/site_perl install
popd

rm -rf git-2.44.0

################icu4c-74_2-src.tgz#################
tar xvf icu4c-74_2-src.tgz

pushd icu4c-74_2-src
    cd source                                    &&

    ./configure --prefix=/usr                    &&
    make
    make install
popd

rm -rf icu4c-74_2-src

################libxml2-2.12.5.tar.xz#################
tar xvf libxml2-2.12.5.tar.xz

pushd libxml2-2.12.5
    ./configure --prefix=/usr           \
                --sysconfdir=/etc       \
                --disable-static        \
                --with-history          \
                --with-icu              \
                PYTHON=/usr/bin/python3 \
                --docdir=/usr/share/doc/libxml2-2.12.5 &&
    make
    make install
    rm -vf /usr/lib/libxml2.la &&
    sed '/libs=/s/xml2.*/xml2"/' -i /usr/bin/xml2-config
popd

rm -rf libxml2-2.12.5

################lzo-2.10.tar.gz#################
tar xvf lzo-2.10.tar.gz

pushd lzo-2.10
    ./configure --prefix=/usr                    \
                --enable-shared                  \
                --disable-static                 \
                --docdir=/usr/share/doc/lzo-2.10 &&
    make
    make install
popd

rm -rf lzo-2.10
################libarchive-3.7.2.tar.xz#################
tar xvf libarchive-3.7.2.tar.xz

pushd libarchive-3.7.2
    ./configure --prefix=/usr --disable-static &&
    make
    make install
popd

rm -rf libarchive-3.7.2

################libuv-v1.48.0.tar.gz#################
tar xvf libuv-v1.48.0.tar.gz

pushd libuv-v1.48.0
    sh autogen.sh                              &&
    ./configure --prefix=/usr --disable-static &&
    make 
    make install
popd

rm -rf libuv-v1.48.0
################nghttp2-1.59.0 #################
tar xvf nghttp2-1.59.0.tar.xz

pushd nghttp2-1.59.0
    ./configure --prefix=/usr     \
                --disable-static  \
                --enable-lib-only \
                --docdir=/usr/share/doc/nghttp2-1.59.0 &&
    make
    make install
popd

rm -rf nghttp2-1.59.0

################cmake-3.28.3.tar.gz#################
tar xvf cmake-3.28.3.tar.gz

pushd cmake-3.28.3
    sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&
    ./bootstrap --prefix=/usr        \
                --system-libs        \
                --mandir=/share/man  \
                --no-system-jsoncpp  \
                --no-system-cppdap   \
                --no-system-librhash \
                --docdir=/share/doc/cmake-3.28.3 &&
    make
    make install
popd

rm -rf cmake-3.28.3
################fish-3.7.1.tar.xz#################
tar xvf fish-3.7.1.tar.xz

pushd fish-3.7.1
    mkdir build
    pushd build
        cmake ..
        make
        make install
    popd
popd

rm -rf fish-3.7.1

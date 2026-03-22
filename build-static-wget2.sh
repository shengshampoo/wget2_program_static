#! /bin/bash

set -e

WORKSPACE=/tmp/workspace
mkdir -p $WORKSPACE
mkdir -p /work/artifact

# libidn2
cd $WORKSPACE
curl -sL https://ftp.gnu.org/gnu/libidn/libidn2-2.3.8.tar.gz | tar x --gzip
cd libidn2-2.3.8
LDFLAGS="-static --static -no-pie -s"  ./configure --prefix=/usr --disable-doc --disable-nls --disable-shared --with-included-libunistring
make
make install

# brotil
cd $WORKSPACE
git clone https://github.com/google/brotli.git
cd brotli
mkdir build
cd build
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=OFF ..
ninja
ninja install

# lzlib
cd $WORKSPACE
curl -sL https://download.savannah.gnu.org/releases/lzip/lzlib/lzlib-1.16.tar.gz | tar x --gzip
cd lzlib-1.16
LDFLAGS="-static --static -no-pie -s" ./configure --prefix=/usr
make
make install

# libmicrohttpd
cd $WORKSPACE
curl -sL https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-1.0.2.tar.gz | tar x --gzip
cd libmicrohttpd-1.0.2
LDFLAGS="-static --static -no-pie -s" ./configure --prefix=/usr
make
make install

# libhsts
cd $WORKSPACE
git clone https://gitlab.com/rockdaboot/libhsts
cd libhsts
autoreconf -fi
LDFLAGS="-static --static -no-pie -s" ./configure --prefix=/usr
make
make install

# wget2
cd $WORKSPACE
git clone https://github.com/rockdaboot/wget2
cd wget2
git clone --recursive https://github.com/coreutils/gnulib.git
./bootstrap
LDFLAGS="-static --static -no-pie -s -lidn2 -lunistring -lbrotlienc -lbrotlidec -lbrotlicommon -lgpgmepp -lgpgme -lgpg-error -lassuan"  ./configure --with-ssl=openssl --with-lzma --with-gpgme --prefix=/usr/local/wget2mm --with-bzip2 --enable-manylibs --disable-shared
make
make install

cd /usr/local
tar vcJf ./wget2mm.tar.xz wget2mm

mv ./wget2mm.tar.xz /work/artifact/

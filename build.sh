#! /bin/bash
set -e
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG
trap 'echo FAILED COMMAND: $previous_command' EXIT

#-------------------------------------------------------------------------------------------
# This script will download packages for, configure, build and install a GCC cross-compiler.
# Customize the variables (INSTALL_PATH, TARGET, etc.) to your liking before running.
# If you get an error and need to resume the script from some point in the middle,
# just delete/comment the preceding lines before running it again.
#
# See: http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler
#-------------------------------------------------------------------------------------------

INSTALL_PATH=/opt/cross
TARGET=arm-armv6l-linux-gnueabi
USE_NEWLIB=0
LINUX_ARCH=arm
CONFIGURATION_OPTIONS=" --enable-threads --disable-libmudflap --disable-libssp --disable-libstdcxx-pch --enable-extra-sgxxlite-multilibs --with-arch=armv6 --with-gnu-as --with-gnu-ld --enable-shared --enable-lto --enable-symvers=gnu --enable-__cxa_atexit --disable-nls --enable-poison-system-directories" # --disable-threads --disable-shared
PARALLEL_MAKE=-j8
BINUTILS_VERSION=binutils-2.30
GCC_VERSION=gcc-8.1.0
LINUX_KERNEL_VERSION=linux-3.0.56
GLIBC_VERSION=glibc-2.20
#GLIBC_PORTS_VERSION=glibc-ports-2.20
#MPFR_VERSION=mpfr-4.0.1
#GMP_VERSION=gmp-6.1.0
#MPC_VERSION=mpc-1.0.3
ISL_VERSION=isl-0.18
CLOOG_VERSION=cloog-0.18.1
export PATH=$INSTALL_PATH/bin:$PATH

# Download packages
export http_proxy=$HTTP_PROXY https_proxy=$HTTP_PROXY ftp_proxy=$HTTP_PROXY
[ ! -f $BINUTILS_VERSION.tar.gz ] && rm -f binutils*.tar.gz && wget -nc https://ftp.gnu.org/gnu/binutils/$BINUTILS_VERSION.tar.gz
[ ! -f $GCC_VERSION.tar.gz ] && rm -f gcc*.tar.gz && wget -nc https://ftp.gnu.org/gnu/gcc/$GCC_VERSION/$GCC_VERSION.tar.gz
if [ $USE_NEWLIB -ne 0 ]; then
    [ ! -f newlib-master.zip ] && wget -nc -O newlib-master.zip https://github.com/bminor/newlib/archive/master.zip || true
    unzip -qo newlib-master.zip
else
    [ ! -f $LINUX_KERNEL_VERSION.tar.xz ] && rm -f linux*.tar.gz && wget -nc https://www.kernel.org/pub/linux/kernel/v3.x/$LINUX_KERNEL_VERSION.tar.xz
    [ ! -f $GLIBC_VERSION.tar.gz ] && rm -f glibc*.tar.gz && wget -nc https://ftp.gnu.org/gnu/glibc/$GLIBC_VERSION.tar.gz
    #[ ! -f $GLIBC_PORTS_VERSION.tar.gz ] && wget -nc https://ftp.gnu.org/gnu/glibc/$GLIBC_PORTS_VERSION.tar.gz
fi
#[ ! -f $MPFR_VERSION.tar.gz ] && rm -rf mpfr* && wget -nc https://ftp.gnu.org/gnu/mpfr/$MPFR_VERSION.tar.gz
#[ ! -f $GMP_VERSION.tar.xz ] && rm -rf gmp* && wget -nc https://ftp.gnu.org/gnu/gmp/$GMP_VERSION.tar.xz
#[ ! -f $MPC_VERSION.tar.gz ] && rm -rf mpc* && wget -nc https://ftp.gnu.org/gnu/mpc/$MPC_VERSION.tar.gz
[ ! -f $ISL_VERSION.tar.bz2 ] && rm -rf isl* && wget -nc ftp://gcc.gnu.org/pub/gcc/infrastructure/$ISL_VERSION.tar.bz2
[ ! -f $CLOOG_VERSION.tar.gz ] && rm -rf cloog* && wget -nc ftp://gcc.gnu.org/pub/gcc/infrastructure/$CLOOG_VERSION.tar.gz

find . -maxdepth 1 -type d -name "[a-zA-Z]*" | xargs rm -r || true

# Extract everything
for f in *.tar*; do 
  tar xf $f; 
done

echo "Download completed..."
echo "[Press any key to continue]"
read

# Make symbolic links
cd $GCC_VERSION
./contrib/download_prerequisites
#ln -sf `ls -1d ../mpfr-*/` mpfr
#ln -sf `ls -1d ../gmp-*/` gmp
#ln -sf `ls -1d ../mpc-*/` mpc
ln -sf `ls -1d ../isl-*/` isl
ln -sf `ls -1d ../cloog-*/` cloog
cd ..

# Step 1. Binutils
mkdir -p build-binutils
cd build-binutils
../$BINUTILS_VERSION/configure --prefix=$INSTALL_PATH --target=$TARGET $CONFIGURATION_OPTIONS
make $PARALLEL_MAKE
make install
cd ..

# Step 2. Linux Kernel Headers
if [ $USE_NEWLIB -eq 0 ]; then
    cd $LINUX_KERNEL_VERSION
    make ARCH=$LINUX_ARCH INSTALL_HDR_PATH=$INSTALL_PATH/$TARGET headers_install
    cd ..
fi

# Step 3. C/C++ Compilers
mkdir -p build-gcc
cd build-gcc
if [ $USE_NEWLIB -ne 0 ]; then
    NEWLIB_OPTION=--with-newlib
fi
../$GCC_VERSION/configure --prefix=$INSTALL_PATH --target=$TARGET --enable-languages=c,c++ $CONFIGURATION_OPTIONS $NEWLIB_OPTION
make $PARALLEL_MAKE all-gcc
make install-gcc
cd ..

if [ $USE_NEWLIB -ne 0 ]; then
    # Steps 4-6: Newlib
    mkdir -p build-newlib
    cd build-newlib
    ../newlib-master/configure --prefix=$INSTALL_PATH --target=$TARGET $CONFIGURATION_OPTIONS
    make $PARALLEL_MAKE
    make install
    cd ..
else
    # Step 4. Standard C Library Headers and Startup Files
    #cd $GLIBC_VERSION
    #ln -sf `ls -1d ../glibc-ports-*/` ports
    #cd ..
    mkdir -p build-glibc
    cd build-glibc
    ../$GLIBC_VERSION/configure --prefix=$INSTALL_PATH/$TARGET --build=$MACHTYPE --host=$TARGET --target=$TARGET --with-headers=$INSTALL_PATH/$TARGET/include $CONFIGURATION_OPTIONS libc_cv_forced_unwind=yes
    make install-bootstrap-headers=yes install-headers
    make $PARALLEL_MAKE csu/subdir_lib
    install csu/crt1.o csu/crti.o csu/crtn.o $INSTALL_PATH/$TARGET/lib
    $TARGET-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $INSTALL_PATH/$TARGET/lib/libc.so
    touch $INSTALL_PATH/$TARGET/include/gnu/stubs.h
    cd ..

    # Step 5. Compiler Support Library
    cd build-gcc
    make $PARALLEL_MAKE all-target-libgcc
    make install-target-libgcc
    cd ..

    # Step 6. Standard C Library & the rest of Glibc
    cd build-glibc
    make $PARALLEL_MAKE
    make install
    cd ..
fi

# Step 7. Standard C++ Library & the rest of GCC
cd build-gcc
make $PARALLEL_MAKE all
make install
cd ..

trap - EXIT
echo 'Success!'

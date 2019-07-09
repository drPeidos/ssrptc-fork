#!/bin/bash

set -u -e -x

export SRCDIR=$(pwd)/source
export BUILDDIR=$(pwd)/build
export TARGETMACH=sh-elf
export BUILDMACH=x86_64-pc-linux-gnu
export HOSTMACH=x86_64-pc-linux-gnu
export INSTALLDIR=$(pwd)/toolchain
export SYSROOTDIR=$INSTALLDIR/sysroot
export ROOTDIR=$(pwd)
export DOWNLOADDIR=$(pwd)/download
export PROGRAM_PREFIX=saturn-sh2-

export BINUTILSVER=2.27
export BINUTILSREV=
export GCCVER=6.2.0
export GCCREV=
export NEWLIBVER=2.4.0
export NEWLIBREV=
export MPCVER=1.0.3
export MPCREV=
export MPFRVER=3.1.5
export MPFRREV=
export GMPVER=6.1.1
export GMPREV=

export OBJFORMAT=ELF

export BINUTILS_CFLAGS="-s"
export GCC_BOOTSTRAP_FLAGS="--with-cpu=m2"
export GCC_FINAL_FLAGS="--with-cpu=m2 --with-sysroot=$SYSROOTDIR"
export NCPU=1

export INSTALLDIR="$(pwd)/install"


function download_and_verify
{

    if [ ! -d $DOWNLOADDIR ]; then
        mkdir -p $DOWNLOADDIR
    fi

    cd $DOWNLOADDIR
    
    FETCH="wget -c"
    
    $FETCH https://ftp.gnu.org/gnu/gnu-keyring.gpg
    $FETCH https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILSVER}${BINUTILSREV}.tar.bz2.sig
    $FETCH https://ftp.gnu.org/gnu/gcc/gcc-${GCCVER}${GCCREV}/gcc-${GCCVER}${GCCREV}.tar.bz2.sig
    $FETCH https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILSVER}${BINUTILSREV}.tar.bz2
    $FETCH https://ftp.gnu.org/gnu/gcc/gcc-${GCCVER}${GCCREV}/gcc-${GCCVER}${GCCREV}.tar.bz2
    $FETCH https://sourceware.org/pub/newlib/newlib-${NEWLIBVER}${NEWLIBREV}.tar.gz
    $FETCH https://ftp.gnu.org/gnu/mpc/mpc-${MPCVER}${MPCREV}.tar.gz.sig
    $FETCH https://ftp.gnu.org/gnu/mpc/mpc-${MPCVER}${MPCREV}.tar.gz
    $FETCH https://ftp.gnu.org/gnu/mpfr/mpfr-${MPFRVER}${MPFRREV}.tar.bz2.sig
    $FETCH https://ftp.gnu.org/gnu/mpfr/mpfr-${MPFRVER}${MPFRREV}.tar.bz2
    $FETCH https://gmplib.org/download/gmp/gmp-${GMPVER}${GMPREV}.tar.bz2.sig
    $FETCH https://gmplib.org/download/gmp/gmp-${GMPVER}${GMPREV}.tar.bz2
    
    # GPG return status
    # 1 == bad signature
    # 2 == no file
    gpg --verify --keyring ./gnu-keyring.gpg binutils-${BINUTILSVER}${BINUTILSREV}.tar.bz2.sig
    if [ $? -ne 0 ]; then
        if [ $? -ne 0 ]; then
            echo "Failed to verify GPG signature for binutils"
            exit 1
        fi
    fi
    
    gpg --verify --keyring ./gnu-keyring.gpg gcc-${GCCVER}${GCCREV}.tar.bz2.sig
    if [ $? -ne 0 ]; then
        if [ $? -ne 0 ]; then
            echo "Failed to verify GPG signautre for gcc"
            exit 1
        fi
    fi
    
    if [ -n "${MPCVER}" ]; then
        gpg --verify --keyring ./gnu-keyring.gpg mpc-${MPCVER}${MPCREV}.tar.gz.sig
        if [ $? -ne 0 ]; then
            if [ $? -ne 0 ]; then
                echo "Failed to verify GPG signautre for mpc"
                exit 1
            fi
        fi
    fi
    
    if [ -n "${MPFRVER}" ]; then
        gpg --verify --keyring ./gnu-keyring.gpg mpfr-${MPFRVER}${MPFRREV}.tar.bz2.sig 
        if [ $? -ne 0 ]; then
            if [ $? -ne 0 ]; then
                echo "Failed to verify GPG signautre for mpfr"
                exit 1
            fi
        fi
    fi
    cd ..

}


function extract-source
{

    echo "Extracting source files..."
    
    if [ ! -d $SRCDIR ]; then
        mkdir -p $SRCDIR
    fi
    
    cd $SRCDIR
    
    if [ ! -d binutils-${BINUTILSVER} ]; then
        tar xvjpf $DOWNLOADDIR/binutils-${BINUTILSVER}${BINUTILSREV}.tar.bz2
        if [ $? -ne 0 ]; then
            rm -rf binutils-${BINUTILSVER}
            exit 1
        fi
        cd $SRCDIR
    fi
    
    if [ ! -d gcc-${GCCVER} ]; then
        tar xvjpf $DOWNLOADDIR/gcc-${GCCVER}${GCCREV}.tar.bz2
        if [ $? -ne 0 ]; then
            rm -rf gcc-${GCCVER}
            exit 1
        fi
    fi
    
    if [ ! -d newlib-${NEWLIBVER} ]; then
        tar xvzpf $DOWNLOADDIR/newlib-${NEWLIBVER}${NEWLIBREV}.tar.gz
        if [ $? -ne 0 ]; then
            rm -rf newlib-${NEWLIBVER}
            exit 1
        fi
    fi
    
    if [ -n "${MPCVER}" ]; then
        if [ ! -d mpc-${MPCVER} ]; then
            tar xvpf $DOWNLOADDIR/mpc-${MPCVER}${MPCREV}.tar.gz
            if [ $? -ne 0 ]; then
                rm -rf mpc-${MPCVER}
                exit 1
            fi
        fi
        cp -rv mpc-${MPCVER} gcc-${GCCVER}/mpc
    fi
    
    if [ -n "${MPFRVER}" ]; then
        if [ ! -d mpfr-${MPFRVER} ]; then
            tar xvjpf $DOWNLOADDIR/mpfr-${MPFRVER}${MPFRREV}.tar.bz2
            if [ $? -ne 0 ]; then
                rm -rf mpfr-${MPFRVER}
                exit 1
            fi
        fi
        cp -rv mpfr-${MPFRVER} gcc-${GCCVER}/mpfr
    fi
    
    if [ -n "${GMPVER}" ]; then
        if [ ! -d gmp-${GMPVER} ]; then
            tar xvjpf $DOWNLOADDIR/gmp-${GMPVER}${GMPREV}.tar.bz2
            if [ $? -ne 0 ]; then
                rm -rf gmp-${GMPVER}
                exit 1
            fi
        fi
        cp -rv gmp-${GMPVER} gcc-${GCCVER}/gmp
    fi
    
    echo "Done"
    
    cd ..

}


function patch-binutils-gcc
{

if [ -d $ROOTDIR/patches/binutils/${BINUTILSVER}${BINUTILSREV} ]; then
    cd $SRCDIR
    for file in $ROOTDIR/patches/binutils/${BINUTILSVER}${BINUTILSREV}/*.patch; do
        patch -Np1 -i $file
        if [ $? -eq 0 ]; then
            echo "Patched ${file}"
        elif [ $? -eq 1 ]; then
            echo "Already applied patch ${file}"
        else
            echo "Failed to apply patch ${file}"
            exit 1
        fi
    done
fi

if [ -d $ROOTDIR/patches/gcc/${GCCVER}${GCCREV} ]; then
    cd $SRCDIR
    for file in $ROOTDIR/patches/gcc/${GCCVER}${GCCREV}/*.patch; do
        patch -Np1 -i $file
        if [ $? -eq 0 ]; then
            echo "Patched ${file}"
        elif [ $? -eq 1 ]; then
            echo "Already applied patch ${file}"
        else
            echo "Failed to apply patch ${file}"
            exit 1
        fi
    done
fi

}


function build-binutils
{

    [ -d $BUILDDIR/binutils ] && rm -rf $BUILDDIR/binutils
    
    mkdir -p $BUILDDIR/binutils
    cd $BUILDDIR/binutils
    
    export CFLAGS=${BINUTILS_CFLAGS}
    export CXXFLAGS="-s"
    
    $SRCDIR/binutils-${BINUTILSVER}/configure \
        --disable-werror --host=$HOSTMACH --build=$BUILDMACH --target=$TARGETMACH \
        --prefix=$INSTALLDIR --with-sysroot=$SYSROOTDIR \
        --program-prefix=${PROGRAM_PREFIX} --disable-nls --enable-languages=c
    
    make -j${NCPU}
    make install -j${NCPU}
    
    cd ..

}


function build-gcc-bootstrap
{

    [ -d $BUILDDIR/gcc-bootstrap ] && rm -rf $BUILDDIR/gcc-bootstrap
    
    mkdir -p $BUILDDIR/gcc-bootstrap
    cd $BUILDDIR/gcc-bootstrap
    
    export PATH=$INSTALLDIR/bin:$PATH
    export CFLAGS="-s"
    export CXXFLAGS="-s"
    
    `realpath --relative-to=./ ${SRCDIR}/gcc-${GCCVER}`/configure \
        --build=$BUILDMACH --host=$HOSTMACH --target=$TARGETMACH \
        --prefix=$INSTALLDIR --without-headers --enable-bootstrap \
        --enable-languages=c,c++ --disable-threads --disable-libmudflap \
        --with-gnu-ld --with-gnu-as --with-gcc --disable-libssp --disable-libgomp \
        --disable-nls --disable-shared --program-prefix=${PROGRAM_PREFIX} \
        --with-newlib --disable-multilib --disable-libgcj \
        --without-included-gettext --disable-libstdcxx \
        ${GCC_BOOTSTRAP_FLAGS}
    
    #if [[ "${HOSTMACH}" != "${BUILDMACH}" ]]; then
    #    # There should be a check for if gcc/auto-build.h exists
    #    cp ./gcc/auto-host.h ./gcc/auto-build.h
    #    mkdir gcc
    #    cp $ROOTDIR/auto-host.h ./gcc/auto-build.h
    #fi
    
    make all-gcc -j${NCPU}
    make install-gcc -j${NCPU}
    
    make all-target-libgcc -j${NCPU}
    make install-target-libgcc -j${NCPU}

}


function build-newlib
{
    
    [ -d $BUILDDIR/newlib ] && rm -rf $BUILDDIR/newlib
    
    mkdir -p $BUILDDIR/newlib
    cd $BUILDDIR/newlib
    
    export PATH=$INSTALLDIR/bin:$PATH
    export CROSS=${PROGRAM_PREFIX}
    export CC_FOR_TARGET=${CROSS}gcc
    export LD_FOR_TARGET=${CROSS}ld
    export AS_FOR_TARGET=${CROSS}as
    export AR_FOR_TARGET=${CROSS}ar
    export RANLIB_FOR_TARGET=${CROSS}ranlib
    
    #export newlib_cflags="${newlib_cflags} -DPREFER_SIZE_OVER_SPEED -D__OPTIMIZE_SIZE__"
    export newlib_cflags="-DPREFER_SIZE_OVER_SPEED -D__OPTIMIZE_SIZE__"
    
    $SRCDIR/newlib-${NEWLIBVER}/configure --prefix=$INSTALLDIR \
        --target=$TARGETMACH --build=$BUILDMACH --host=$HOSTMACH \
        --enable-newlib-nano-malloc --enable-target-optspace
    
    make all -j${NCPU}
    make install -j${NCPU}
    
}


function build-libstdcpp
{

    [ -d $BUILDDIR/libstdc++ ] && rm -rf $BUILDDIR/libstdc++
    
    mkdir -p $BUILDDIR/libstdc++
    cd $BUILDDIR/libstdc++
    
    export PATH=$INSTALLDIR/bin:$PATH
    export CROSS=${PROGRAM_PREFIX}
    export CC=${CROSS}gcc
    export CXX=${CROSS}g++
    export CPP=${CROSS}cpp
    
    $SRCDIR/gcc-${GCCVER}/libstdc++-v3/configure \
        --host=${TARGETMACH} --build=${BUILDMACH} --target=${TARGETMACH} \
        --with-cross-host=${HOSTMACH} --prefix=${INSTALLDIR} --disable-nls \
        --disable-multilib --disable-libstdcxx-threads --with-newlib \
        --disable-libstdcxx-pch
    
    make
    #-j${NCPU}
    make install -j${NCPU}

}


function build-gcc-final
{
    [ -d $BUILDDIR/gcc-final ] && rm -rf $BUILDDIR/gcc-final
    
    mkdir $BUILDDIR/gcc-final
    cd $BUILDDIR/gcc-final
    
    #echo "libc_cv_forced_unwind=yes" > config.cache
    #echo "libc_ctors_header=yes" >> config.cache
    #echo "libc_cv_c_cleanup=yes" >> config.cache
    
    export CFLAGS="-s"
    export CXXFLAGS="-s"
    
    export PATH=$INSTALLDIR/bin:$PATH
    
    `realpath --relative-to=./ ${SRCDIR}/gcc-${GCCVER}`/configure \
        --build=$BUILDMACH --target=$TARGETMACH --host=$HOSTMACH \
        --prefix=$INSTALLDIR --enable-languages=c,c++ \
        --with-gnu-as --with-gnu-ld --disable-shared --disable-threads \
        --disable-multilib --disable-libmudflap --disable-libssp --enable-lto \
        --disable-nls --with-newlib \
        --program-prefix=${PROGRAM_PREFIX} ${GCC_FINAL_FLAGS}
    
    make -j${NCPU}
    make install -j${NCPU}

}




#if [ ! -d $INSTALLDIR ]
#    mkdir -p $INSTALLDIR
#else
#    rm -rf $INSTALLDIR
#fi


download_and_verify
extract-source
patch-binutils-gcc
build-binutils
build-gcc-bootstrap
build-newlib
build-libstdcpp
build-gcc-final

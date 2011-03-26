. gen.conf `pwd`


if [ ! -d $source_path ]; then
  mkdir $source_path
fi

if [ ! -d $object_path ]; then
  mkdir $object_path
fi

if [ ! -d $object_path/toolchain ]; then
  mkdir $object_path/toolchain
fi

fetch() {

  echo "Downloading packages"
  if [ ! -d $dw_path ]; then
    mkdir $dw_path
  fi

  pushd $dw_path
  wget -c $autoconf_download
  wget -c $automake_download
  wget -c $binutils_download
  wget -c $bison_download
  wget -c $bzip2_download
  wget -c $coreutils_download
  wget -c $dash_download
  wget -c $diffutils_download
  wget -c $e2fsprogs_download
  wget -c $file_download
  wget -c $findutils_download
  wget -c $flex_download
  wget -c $gawk_download
  wget -c $gcc_download
  wget -c $gdbm_download
  wget -c $gettext_download
  wget -c $glibc_download
  wget -c $gmp_download
  wget -c $grep_download
  wget -c $groff_download
  wget -c $gzip_download
  wget -c $libtool_download
  wget -c $linux_download
  wget -c $m4_download
  wget -c $make_download
  wget -c $module_init_tools_download
  wget -c $mpc_download
  wget -c $mpfr_download
  wget -c $ncurses_download
  wget -c $patch_download
  wget -c $perl_download
  wget -c $pkg_config_download
  wget -c $procps_download
  wget -c $psmisc_download
  wget -c $readline_download
  wget -c $sed_download
  wget -c $shadow_download
  wget -c $tar_download
  wget -c $tcl_download
  wget -c $util_linux_download
  wget -c $zlib_download
  popd
}

setup() {
  export LC_ALL=POSIX
  export TARGET=${targetarch}-${toolchainname}-linux-gnu
  export PATH=${object_path}/toolchain/bin:${PATH}
}

extract() {

  pushd $source_path
  echo "Extract toolchain source"
  for package in $dw_path/*; do
    tar -xf $package;
  done

  mv $source_path/mpfr-${mpfr_version} $source_path/gcc-${gcc_version}/mpfr
  mv $source_path/gmp-${gmp_version} $source_path/gcc-${gcc_version}/gmp
  mv $source_path/mpc-${mpc_version} $source_path/gcc-${gcc_version}/mpc

  popd

}

build_init_toolchain() {

  echo "Building initial toolchain"
  if [ ! -d $build_path ]; then
    mkdir $build_path
  fi

  build_binutils_1

}

build_binutils_1() {
  mkdir $build_path/binutils-build
  pushd $build_path/binutils-build
  $source_path/binutils-${binutils_version}/configure --target $TARGET \
    --prefix=$object_path/toolchain --disable-nls --disable-werror
  make
  make install
  popd
}

build_gcc_1() {
  mkdir $build_path/gcc-build
  pushd $build_path/gcc-build

  $source_path/gcc-${gcc_version}/configure --target $TARGET \
    --prefix=$object_path/toolchain --disable-nls --disable-shared \
    --disable-multilib --disable-decimal-float --disable-threads \
    --disable-libmudflap --disable-libssp  --disable-libgomp \
    --enable-languages=c --with-gmp-includes=$(pwd)/gmp \
    --with-gmp-lib=$(pwd)/gmp/.libs --without-ppl --without-cloog

  make
  make install
  ln -vs libgcc.a $($TARGET-gcc -print-libgcc-file-name | \
    sed 's/libgcc/&_eh/')

  popd
}

build_headers() {
  pushd $source_path/linux-${linux_version}
  make mrproper
  make headers_check
  make INSTALL_HDR_PATH=${object_path}/toolchain/ headers_install
  popd
}

build_glibc_1() {
  mkdir $build_path/build-glibc
  pushd $build_path/build_glibc

  $source_path/glibc-${glibc_version}/configure --prefix=$object_path/toolchain \
    --host=$TARGET \
    --build=$($source_path/glibc-${glibc-version}/scripts/config.guess) \
    --disable-profile --enable-add-ons --enable-kernel=${linux_version} \
    --with-headers=$object_path/toolchain/include

  make
  make install
  popd
}





setup
case "$1" in
  fetch)
    fetch ;;
  extract)
    extract ;;
  *)
    echo "Unsupported option" ;;
esac


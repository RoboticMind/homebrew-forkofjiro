class Gridcoin < Formula
  desc "OS X client (GUI and CLI)"
  homepage "https://gridcoin.us/"
  url "https://github.com/gridcoin-community/Gridcoin-Research/archive/5.1.0.0.tar.gz"
  sha256 "a4c84664ca199de0a07c94b79030d13eafc7ee8ab9ef7a05a5de8f62fb82190b"
  head "https://github.com/gridcoin/Gridcoin-Research.git", :branch => "development"

  def caveats
    s = ""
    s += "--HEAD uses Gridcoin's development branch.\n"
    s += "Please refer to https://github.com/gridcoin/Gridcoin-Research/blob/master/README.md for Gridcoin's branching strategy\n"
    s
  end

  stable do
    patch <<-EOS
      diff --git a/configure.ac b/configure.ac
      index eb96af9c..8b692612 100644
      --- a/configure.ac
      +++ b/configure.ac
      @@ -829,5 +823,5 @@
       if test x$use_boost = xyes; then
       
      -BOOST_LIBS="$BOOST_LDFLAGS $BOOST_SYSTEM_LIB $BOOST_FILESYSTEM_LIB $BOOST_ZLIB_LIB $BOOST_IOSTREAMS_LIB $BOOST_PROGRAM_OPTIONS_LIB $BOOST_THREAD_LIB $BOOST_CHRONO_LIB $BOOST_ZLIB_LIB"
      +BOOST_LIBS="$BOOST_LDFLAGS $BOOST_SYSTEM_LIB $BOOST_FILESYSTEM_LIB $BOOST_ZLIB_LIB $BOOST_IOSTREAMS_LIB $BOOST_PROGRAM_OPTIONS_LIB $BOOST_THREAD_LIB $BOOST_CHRONO_LIB $BOOST_ZLIB_LIB -lboost_system-mt"
       
       
      @@ -1171,5 +1165,7 @@ echo "  CFLAGS        = $CFLAGS"
       echo "  CPPFLAGS      = $CPPFLAGS"
       echo "  CXX           = $CXX"
       echo "  CXXFLAGS      = $CXXFLAGS"
      +echo "  OBJCXX        = $OBJCXX"
      +echo "  OBJCXXFLAGS   = $OBJCXXFLAGS"
       echo "  LDFLAGS       = $LDFLAGS"
       echo
    EOS
  end

  option "without-upnp", "Do not compile with UPNP support"
  option "with-cli", "Also compile the command line client"
  option "without-gui", "Do not compile the graphical client"

  depends_on "boost"
  depends_on "berkeley-db@4"
  depends_on "leveldb"
  depends_on "openssl"
  depends_on "miniupnpc"
  depends_on "libzip"
  depends_on "pkg-config" => :build
  depends_on "qrencode"
  depends_on "qt"
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "librsvg" => :build

  def install
    if build.with? "upnp"
      upnp_build_var = "1"
    else
      upnp_build_var = "-"
    end

    if build.with? "cli"
      chmod 0755, "src/leveldb/build_detect_platform"
      mkdir_p "src/obj/zerocoin"
      system "make", "-C", "src", "-f", "makefile.osx", "USE_UPNP=#{upnp_build_var}"
      bin.install "src/gridcoinresearchd"
    end

    if build.with? "gui"
      args = %W[
        BOOST_INCLUDE_PATH=#{Formula["boost"].include}
        BOOST_LIB_PATH=#{Formula["boost"].lib}
        OPENSSL_INCLUDE_PATH=#{Formula["openssl"].include}
        OPENSSL_LIB_PATH=#{Formula["openssl"].lib}
        BDB_INCLUDE_PATH=#{Formula["berkeley-db@4"].include}
        BDB_LIB_PATH=#{Formula["berkeley-db@4"].lib}
        MINIUPNPC_INCLUDE_PATH=#{Formula["miniupnpc"].include}
        MINIUPNPC_LIB_PATH=#{Formula["miniupnpc"].lib}
        QRENCODE_INCLUDE_PATH=#{Formula["qrencode"].include}
        QRENCODE_LIB_PATH=#{Formula["qrencode"].lib}
      ]

      system "./autogen.sh"
      system "unset OBJCXX ; ./configure --disable-asm"
      system "make appbundle"
      prefix.install "gridcoinresearch.app"
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test Gridcoin`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

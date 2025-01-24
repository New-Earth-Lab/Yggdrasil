# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libmd"
version = v"1.1.0"

# Collection of sources required to build libcap
sources = [
    ArchiveSource("https://libbsd.freedesktop.org/releases/libmd-$(version).tar.xz",
                  "1bd6aa42275313af3141c7cf2e5b964e8b1fd488025caf2f971f43b00776b332")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/libmd-*/

./configure --prefix=${prefix} --build=${MACHTYPE} --host=${target}
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line.  We are manually disabling
# many platforms that do not seem to work.
platforms = [p for p in supported_platforms() if Sys.islinux(p) || Sys.iswindows(p)]

# The products that we will ensure are always built
products = [
    LibraryProduct("libmd", :libmd),
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.6")
# GCC bump for an objcopy with --dump-sections support

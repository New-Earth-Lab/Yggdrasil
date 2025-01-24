# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libbsd"
version = v"0.12.2"

# Collection of sources required to build libcap
sources = [
    ArchiveSource("https://libbsd.freedesktop.org/releases/libbsd-$(version).tar.xz",
                  "b88cc9163d0c652aaf39a99991d974ddba1c3a9711db8f1b5838af2a14731014")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/libbsd-*/

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
    LibraryProduct("libbsd", :libbsd),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("libmd_jll")
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.6")
# GCC bump for an objcopy with --dump-sections support

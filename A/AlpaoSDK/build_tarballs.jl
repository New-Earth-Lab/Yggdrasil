# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "AlpaoSDK"
version = v"4.1.12"

filename = "Alpao_SDK_$(version.major).$(lpad(version.minor, 2, '0')).$(version.patch).zip"

# Collection of sources required to complete build
sources = [ 
    ArchiveSource("./bundled/$(filename)",
        "7b47fe2bb11679c210fad626535f667e0780fb4b6467a4c985ae6ebe8740e75f"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/CDROM

install -d $libdir $includedir
cp ./Include/*.h $includedir

case "${target}" in
    i686-*-mingw*)
        install ./Lib/x86/*.dll $libdir
        ;;
    x86_64-*-mingw*)
        install ./Lib/x64/*.dll $libdir
        ;;
    aarch64-linux-*)
        install ./Linux/Lib/arm64/*.so $libdir
        ;;
    i686-linux-*)
        install ./Linux/Lib/x86/*.so $libdir
        ;;
    x86_64-linux-*)
        install ./Linux/Lib/x64/*.so $libdir
        ;;
esac

echo "PROPRIETARY" > LICENSE
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Platform("i686", "linux", cxxstring_abi="cxx03"),
    Platform("x86_64", "linux", cxxstring_abi="cxx03"),
    Platform("aarch64", "linux", cxxstring_abi="cxx11"),
    Platform("i686", "windows"),
    Platform("x86_64", "windows")
]
platforms = expand_cxxstring_abis(platforms)

# The products that we will ensure are always built
products = Product[
    LibraryProduct(["ASDK", "libasdk"], :libasdk),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("CompilerSupportLibraries_jll"),
    Dependency("LibCURL_jll"; platforms=filter(Sys.islinux, platforms)),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(
    ARGS, name, version, sources, script, platforms, products, dependencies;
    julia_compat="1.6",
)
# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "AndorSDK2"
version = v"2.104.30065"

# Collection of sources required to complete build
sources = [ 
    FileSource("https://andor.oxinst.com/downloads/uploads/AndorDriverPack2Setup-$(version.major).$(version.minor).$(version.patch).0.exe",
        "34f5f0db54852d052dfa9b7dbadb4b2bb355806513b9a0babf5908b9fc4c6b01"),
    DirectorySource("./bundled"),
]

# Bash recipe for building across all platforms
script = raw"""
apk update && apk upgrade && apk add innoextract

innoextract -e -d $WORKSPACE/srcdir $WORKSPACE/srcdir/*.exe
cd $WORKSPACE/srcdir

install -d $libdir $includedir $prefix/share/AndorSDK2

case "${target}" in
    i686-*-mingw*)
        install ./app/atmcd32d.dll $libdir
        cp atmcd32d.h $includedir
        cp ./app/Detector.ini $prefix/share/AndorSDK2
        ;;
    x86_64-*-mingw*)
        install ./app/atmcd64d.dll $libdir
        cp atmcd32d.h $includedir
        cp ./app/Detector.ini $prefix/share/AndorSDK2
        ;;
    # i686-linux-*)
    #     cp atmcdLXd.h $includedir
    #     ;;
    # x86_64-linux-*)
    #     cp atmcdLXd.h $includedir
    #     ;;
esac

echo "PROPRIETARY" > $WORKSPACE/srcdir/LICENSE
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Platform("i686", "windows"),
    Platform("x86_64", "windows")    
]
platforms = expand_cxxstring_abis(platforms)

# The products that we will ensure are always built
products = Product[
    LibraryProduct(["atmcd32d", "atmcd64d"], :libandor2),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("CompilerSupportLibraries_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(
    ARGS, name, version, sources, script, platforms, products, dependencies;
    julia_compat="1.6",
)
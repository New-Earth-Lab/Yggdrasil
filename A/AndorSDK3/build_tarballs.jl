# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "AndorSDK3"
version = v"3.15.30092"

# Collection of sources required to complete build
sources = [ 
    FileSource("https://andor.oxinst.com/downloads/uploads/AndorDriverPack3Setup-$(version.major).$(version.minor).$(version.patch).0.exe",
        "109e533bda0730fae8c4ce39e7369824308824ed51da4e2f3adc876fc8bed05f"),
    # DirectorySource("./bundled"),
]

# Bash recipe for building across all platforms
script = raw"""
apk update && apk upgrade && apk add innoextract

innoextract -e -d $WORKSPACE/srcdir $WORKSPACE/srcdir/*.exe
cd $WORKSPACE/srcdir

install -d $libdir $includedir $prefix/share/AndorSDK3

case "${target}" in
    *-mingw*)
        install ./app/*.dll $libdir
        cp *.h $includedir
        ;;
    # i686-linux-*)
    #     cp *.h $includedir
    #     ;;
    # x86_64-linux-*)
    #     cp *.h $includedir
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
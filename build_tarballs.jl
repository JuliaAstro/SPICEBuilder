# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "cspice"
version = v"66"

# Collection of sources required to build cspice
sources = [
    "http://naif.jpl.nasa.gov/pub/naif/toolkit//C/PC_Linux_GCC_64bit/packages/cspice.tar.Z" =>
    "93cd4fbce5818f8b7fecf3914c5756b8d41fd5bdaaeac1f4037b5a5410bc4768",
    "./extra"
]

# These are the platforms built inside the wizard
platforms = supported_platforms()

script = raw"""
cd $WORKSPACE/srcdir
cp -r cspice/src/cspice/ .

# Create generated cmake files outside of source tree
mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=/ -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain ..
make -j${nproc} VERBOSE=1
make install VERBOSE=1
"""

products = prefix -> [
    LibraryProduct(prefix, "libcspice", :libcspice)
]

# Dependencies that must be installed before this package can be built
dependencies = []

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

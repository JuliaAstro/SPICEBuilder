using BinaryBuilder

# These are the platforms built inside the wizard
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
    BinaryProvider.Linux(:x86_64, :glibc),
    BinaryProvider.Linux(:aarch64, :glibc),
    BinaryProvider.Linux(:armv7l, :glibc),
    BinaryProvider.Linux(:powerpc64le, :glibc),
    BinaryProvider.MacOS(),
    BinaryProvider.Windows(:i686),
    BinaryProvider.Windows(:x86_64)
]


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

# Collection of sources required to build cspice
sources = [
    "http://naif.jpl.nasa.gov/pub/naif/toolkit//C/PC_Linux_GCC_64bit/packages/cspice.tar.Z" =>
    "93cd4fbce5818f8b7fecf3914c5756b8d41fd5bdaaeac1f4037b5a5410bc4768",

    "https://github.com/JuliaAstro/SPICE.jl.git" =>
    "aa78f6c0cc20bd5e36aecb197d5095e8e7735df3",
]

script = raw"""
cd $WORKSPACE/srcdir
cp -r cspice/src/cspice/ .
cp SPICE.jl/deps/CMakeLists.txt .
cp SPICE.jl/deps/src.cmake .
cmake -DCMAKE_INSTALL_PREFIX=/ -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain
make
make install

"""

products = prefix -> [
    LibraryProduct(prefix,"libcspice")
]


# Build the given platforms using the given sources
hashes = autobuild(pwd(), "cspice", platforms, sources, script, products)


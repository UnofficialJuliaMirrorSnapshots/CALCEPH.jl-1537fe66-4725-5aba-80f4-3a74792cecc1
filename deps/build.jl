using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libcalceph"], :libcalceph),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaAstro/CALCEPHBuilder/releases/download/v3.3.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/libcalceph.v3.3.0.aarch64-linux-gnu.tar.gz", "09b578aabce8603a2c2ae1c53d1217f80f63be7a727b714b3c0b7de558a93437"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/libcalceph.v3.3.0.aarch64-linux-musl.tar.gz", "f58a2ce93cd0e3dfa79a4b936a86c2976940d4c13f85371657c28c5edc1c93d7"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/libcalceph.v3.3.0.arm-linux-gnueabihf.tar.gz", "f1e335b559aea1b60468eabb87f498c3d60f79217b3faefa1968a5ad72bd76a2"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/libcalceph.v3.3.0.arm-linux-musleabihf.tar.gz", "3575c38d9e2417123ea767584942c00179665658044f0892e1e2296cc1cd1634"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/libcalceph.v3.3.0.i686-linux-gnu.tar.gz", "f06301d14a424ccee470934d825f219b278ff33eb2bc83b82a8449883d1cd4ad"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/libcalceph.v3.3.0.i686-linux-musl.tar.gz", "41e2301438538e19c2a023fc63a0bde8edf8eec8bb7d1dcfb1caccd0d1c225ac"),
    Windows(:i686) => ("$bin_prefix/libcalceph.v3.3.0.i686-w64-mingw32.tar.gz", "14b6bd40b282deaa4bef8ae3f687b0c3cdcb1ab6bf9ae10e8135ec83fc98f59d"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/libcalceph.v3.3.0.powerpc64le-linux-gnu.tar.gz", "429778118d7216e93c39cbbed6680c0b2e4981c5539f21d794f6765948ae381c"),
    MacOS(:x86_64) => ("$bin_prefix/libcalceph.v3.3.0.x86_64-apple-darwin14.tar.gz", "c6051e5f8661bab996ee4bb5d4c8c13fb7b708be7a4b366b18b3d992c60d16e5"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/libcalceph.v3.3.0.x86_64-linux-gnu.tar.gz", "d0e4ec3d6c63d4812e042de2597689a4ebf916a600162114c5da6daa24c41a73"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/libcalceph.v3.3.0.x86_64-linux-musl.tar.gz", "dfe0b37214814c3c176c61ef1adec48d02781b3b25d6e0c21f2e6676384524ed"),
    FreeBSD(:x86_64) => ("$bin_prefix/libcalceph.v3.3.0.x86_64-unknown-freebsd11.1.tar.gz", "fa1442e167a683bff2541a49b0cba920df49ac4c43c87d35fcf7ed3a57a12ca6"),
    Windows(:x86_64) => ("$bin_prefix/libcalceph.v3.3.0.x86_64-w64-mingw32.tar.gz", "4b84a20dacd329ffa3bdce051016ef16a7b92e13db2a519dad2acdfcdfb39480"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
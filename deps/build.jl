if VERSION >= v"1.3"
    exit()  # Use ECOS_jll instead.
end

using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(
    get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")),
)
products = [LibraryProduct(prefix, String["libecos"], :ecos)]

# Download binaries from hosted location
bin_prefix = "https://github.com/juan-pablo-vielma/ECOSBuilder/releases/download/v2.0.5-beta"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.aarch64-linux-gnu.tar.gz",
        "9e6279a971889df14eaa384c8138136c5918e1a3a97e913d1a23fb3e80d711a6",
    ),
    Linux(:aarch64, :musl) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.aarch64-linux-musl.tar.gz",
        "afeb89f158dbcb506230e35e13ad63ab374a35f8b4ebe3ff4d1c604acb98e79f",
    ),
    Linux(:armv7l, :glibc, :eabihf) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.arm-linux-gnueabihf.tar.gz",
        "2fd091c5581156acc1a135d7ad969563f4a356b2631b3d2f2e215c114960c98b",
    ),
    Linux(:armv7l, :musl, :eabihf) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.arm-linux-musleabihf.tar.gz",
        "776ceedd12467a761354e73641dba4c0e0b34df9e5635360880e0d7f4c347c64",
    ),
    Linux(:i686, :glibc) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.i686-linux-gnu.tar.gz",
        "2b622c881c0c0cb9a12f514a211512b8a0c2404c6e35f4817e0c590095a759aa",
    ),
    Linux(:i686, :musl) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.i686-linux-musl.tar.gz",
        "0318aafa7457e0d1cb9a85e0938498457341d0050036ac24ab05b8f2d0ea7d4f",
    ),
    Windows(:i686) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.i686-w64-mingw32.tar.gz",
        "2c5fba5caed62b5edc1199ebd62e702212197b916f6bab8f7ba30c2c16326117",
    ),
    Linux(:powerpc64le, :glibc) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.powerpc64le-linux-gnu.tar.gz",
        "9d75f00a0bd9ba2aa917f073cb9544f4fb74f0cd711eeb5b06ab13efe70cf16a",
    ),
    MacOS(:x86_64) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.x86_64-apple-darwin14.tar.gz",
        "617f20ee41dbbd34dd7f8cb4c8c5f84bf5e52646886880679d8c116de418fd29",
    ),
    Linux(:x86_64, :glibc) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.x86_64-linux-gnu.tar.gz",
        "69ea265aab6701b9ce2b9c3b6d574bd88f1fd4640527a8d106385359abe88021",
    ),
    Linux(:x86_64, :musl) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.x86_64-linux-musl.tar.gz",
        "52f6c0f3742e316eb15d5180cfa41c6a7985104745f7ede0bf0577087af97384",
    ),
    FreeBSD(:x86_64) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.x86_64-unknown-freebsd11.1.tar.gz",
        "52f2167039d40115a92f428c81e81b3de000cece3756ea9bfcf12c07ef6bd9bc",
    ),
    Windows(:x86_64) => (
        "$bin_prefix/ECOSBuilder.v2.0.5.x86_64-w64-mingw32.tar.gz",
        "f38e30147d12bb06eab3517c314444ffaedf13f252947cb458bd34cddb73e481",
    ),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose = verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    # Check if this build.jl is providing new versions of the binaries, and
    # if so, ovewrite the current binaries even if they were installed by the user
    if unsatisfied || !isinstalled(url, tarball_hash; prefix = prefix)
        # Download and install binaries
        install(
            url,
            tarball_hash;
            prefix = prefix,
            force = true,
            verbose = verbose,
        )
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error(
        "Your platform $(triplet(platform_key())) is not supported by this package!",
    )
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose = verbose)

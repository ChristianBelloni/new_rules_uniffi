load("@rules_rust//rust:defs.bzl", "rust_binary")
load("//uniffi/3rdparty/crates:defs.bzl", "all_crate_deps")

exports_files(srcs = [
    "Cargo.lock",
    "Cargo.toml",
])

rust_binary(
    name = "generate_bin",
    srcs = glob(["**/*.rs"]),
    visibility = ["//visibility:public"],
    deps = all_crate_deps(),
)

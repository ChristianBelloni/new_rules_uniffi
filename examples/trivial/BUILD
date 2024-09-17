load("@crates//:defs.bzl", "all_crate_deps")
load("@rules_rust//rust:defs.bzl", "rust_library")

rust_library(
    name = "trivial_example",
    srcs = glob(["**/*.rs"]),
    compile_data = ["Cargo.toml"],
    deps = all_crate_deps(),
)

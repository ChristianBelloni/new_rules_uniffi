load("@crates//:defs.bzl", "all_crate_deps")
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_library")

uniffi_library(
    name = "trivial",
    package_name = "trivial.example",
    srcs = glob(["**/*.rs"]),
    compile_data = ["Cargo.toml"],
    visibility = [":__subpackages__"],
    deps = all_crate_deps(),
)

platform(
    name = "arm64-v8a",
    constraint_values = [
        "@platforms//cpu:arm64",
        "@platforms//os:android",
    ],
)

test_suite(
    name = "trivial_tests",
    tests = [
        "//android:force_build_apks_test",
        "//kt-jvm:trivial_kt_build_test",
        "//kt-jvm:trivial_kt_test",
        "//swift:trivial_swift_test",
    ],
)

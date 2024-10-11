load("@crates//:defs.bzl", "all_crate_deps")
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_library")
load("@rules_kotlin//kotlin:core.bzl", "define_kt_toolchain")

define_kt_toolchain(
    name = "kotlin_toolchain",
    api_version = "1.9",  # "1.1", "1.2", "1.3", "1.4", "1.5" "1.6", "1.7", "1.8", or "1.9"
    jvm_target = "17", # "1.6", "1.8", "9", "10", "11", "12", "13", "15", "16", "17", "18", "19", "20" or "21"
    language_version = "1.9",  # "1.1", "1.2", "1.3", "1.4", "1.5" "1.6", "1.7", "1.8", or "1.9"
)


uniffi_library(
    name = "trivial",
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

platform(
    name = "darwin-aarch64",
    constraint_values = [
        "@platforms//cpu:arm64",
        "@platforms//os:osx",
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

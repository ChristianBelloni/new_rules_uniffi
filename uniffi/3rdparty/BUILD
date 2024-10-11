load("@rules_android//rules/aar_import:rule.bzl", "aar_import")
load("@rules_rust//crate_universe:defs.bzl", "crates_vendor")
load("@rules_java//java:defs.bzl", "java_binary", "java_import", "java_library", "java_plugin")

package(default_visibility = ["//visibility:public"])

crates_vendor(
    name = "crates_vendor",
    cargo_lockfile = "//uniffi/private/generate:Cargo.lock",
    manifests = ["//uniffi/private/generate:Cargo.toml"],
    mode = "remote",
    # Short for internal deps
    repository_name = "id",
    vendor_path = "crates",
)

alias(
    name = "coroutines",
    actual = "@uniffi_maven//:org_jetbrains_kotlinx_kotlinx_coroutines_core",
)

alias(
    name = "jna",
    actual = "@uniffi_maven//:net_java_dev_jna_jna",
)


java_import(
    name = "android_sdk",
    jars = ["@rules_android//tools/android:android_jar"],
    visibility = ["//visibility:public"],
    neverlink = 1,
)

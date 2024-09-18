load("@rules_android//android:rules.bzl", "aar_import")
load("@rules_rust//crate_universe:defs.bzl", "crates_vendor")

package(default_visibility = ["//visibility:public"])

crates_vendor(
    name = "crates_vendor",
    cargo_lockfile = "//uniffi/private/generate:Cargo.lock",
    manifests = ["//uniffi/private/generate:Cargo.toml"],
    mode = "remote",
    # Short for 'crate universe index'. Keep this short to reduce the risk to
    # bump into absolute path length issues on Windows. See:
    # https://github.com/bazelbuild/rules_rust/issues/1120
    # tags = ["manual"],
    repository_name = "ucr",
    vendor_path = "crates",
)

aar_import(
    name = "jna_aar",
    aar = "@net_java_dev_jna_jna_aar//file:file",
    visibility = ["//visibility:public"],
)

java_import(
    name = "jna_jar",
    jars = ["@net_java_dev_jna_jna_jar//file"],
)

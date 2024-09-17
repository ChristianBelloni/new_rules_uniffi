load("@bazel_tools//tools/build_defs/repo:maven_rules.bzl", "maven_aar", "maven_jar")
load("//uniffi/3rdparty/crates:crates.bzl", "crate_repositories")

def rules_uniffi_dependencies():
    maven_aar(
        name = "net_java_dev_jna_jna",
        artifact = "net.java.dev.jna:jna:5.14.0",
    )
    maven_jar(
        name = "org_jetbrains_kotlinx_kotlinx_coroutines_core",
        artifact = "org.jetbrains.kotlinx:kotlinx-coroutines-core:1.9.0",
    )
    crate_repositories()

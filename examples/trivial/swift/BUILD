load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_swift_library")

uniffi_swift_library(
    name = "trivial_swift",
    library = "//:trivial",
    module_name = "Trivial",
)

swift_binary(
    name = "trivial_swift_bin",
    srcs = ["main.swift"],
    deps = [":trivial_swift"],
)

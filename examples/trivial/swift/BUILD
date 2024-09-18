load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary", "swift_library", "swift_test")
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_swift_library")

uniffi_swift_library(
    name = "trivial_swift",
    library = "//:trivial",
    module_name = "Trivial",
)

swift_library(
    name = "trivial_swift_lib",
    srcs = ["main.swift"],
    copts = ["-parse-as-library"],
    deps = [":trivial_swift"],
)

swift_binary(
    name = "trivial_swift_bin",
    deps = [":trivial_swift_lib"],
)

swift_test(
    name = "trivial_swift_test",
    srcs = ["test.swift"],
    deps = [":trivial_swift"],
)

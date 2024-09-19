load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_swift_library")

uniffi_swift_library(
    name = "trivial_swift",
    library = "//:trivial",
    module_name = "Trivial",
)

swift_library(
    name = "app_lib",
    srcs = ["App.swift"],
    deps = [":trivial_swift"],
)

ios_application(
    name = "App",
    bundle_id = "com.example.app",
    families = ["iphone"],
    infoplists = [":Info.plist"],
    minimum_os_version = "16",
    deps = [":app_lib"],
)

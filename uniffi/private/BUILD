load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "private",
    srcs = glob(["*.bzl"]),
    visibility = ["//uniffi:__subpackages__"],
    deps = [
        "@build_bazel_rules_swift//swift",
        "@rules_android//rules:bzl",
        "@rules_android//rules:common_bzl",
        "@rules_java//java:rules",
        "@rules_kotlin//kotlin",
        "@rules_kotlin//src/main/starlark/core/plugin",
        "@rules_rust//rust:bzl_lib",
    ],
    # deps = [":temp_android"],
)

# bzl_library(
#     name = "temp_android",
#     srcs = glob(["@rules_android/android/*.bzl"]),
# )

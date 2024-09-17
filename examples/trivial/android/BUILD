load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_android//android:binary.bzl", "android_binary")
load("@rules_kotlin//kotlin:android.bzl", "kt_android_library")
load("@rules_uniffi//uniffi:defs.bzl", "rust_kotlin_android_library")

rust_kotlin_android_library(
    name = "trivial_android_kt",
    library = "//:trivial",
)

kt_android_library(
    name = "android_lib",
    srcs = ["MainActivity.kt"],
    data = ["trivial"],
    deps = [
        "trivial_android_kt",
        "@maven//:androidx_appcompat_appcompat",
    ],
)

android_binary(
    name = "trivial_android_bin",
    manifest = "AndroidManifest.xml",
    deps = [
        "android_lib",
        "@maven//:androidx_appcompat_appcompat",
    ],
)

build_test(
    name = "force_build_apks_test",
    targets = [
        "trivial_android_bin.apk",
    ],
)

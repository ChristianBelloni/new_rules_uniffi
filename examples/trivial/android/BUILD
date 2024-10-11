load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_android//rules:rules.bzl", "android_binary", "android_application", "android_local_test")
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_android_library", "kt_android_library", "kt_android_local_test")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library", "kt_jvm_test")
load("@rules_kotlin//kotlin:core.bzl", "kt_compiler_plugin", "kt_ksp_plugin")


uniffi_android_library(
    name = "trivial_android_kt",
    package_name = "com.mypackage.example",
    library = "//:trivial",
)

kt_android_library(
    name = "android_lib",
    srcs = ["MainActivity.kt"],
    exports = [
      "trivial_android_kt",
      "@maven//:androidx_appcompat_appcompat", 
    ],
    deps = [
        "trivial_android_kt",
        "@maven//:androidx_appcompat_appcompat",
    ],
)

kt_android_local_test(
    manifest = "AndroidManifest.xml",
    name = "trivial_test",
    srcs = ["Test.kt"],
    deps = [
      ":android_lib", 
      "@rules_robolectric//bazel:android-all", 
      "@maven//:junit_junit",
      "@maven//:org_robolectric_robolectric",
    ],
    test_class = "com.example.trivial.TrivialTests",
    jvm_flags = ["-Djava.security.manager=allow"],
    data = ["_dylib_trivial_android_kt"]
)

android_binary(
    name = "trivial_android_bin",
    manifest = "AndroidManifest.xml",
    deps = [
        "android_lib",
        "@maven//:androidx_appcompat_appcompat",
    ],
    incremental_dexing = 0,
    multidex = "native",
)

build_test(
    name = "force_build_apks_test",
    targets = [
        "trivial_android_bin.apk",
    ],
    visibility = ["//visibility:public"],
)

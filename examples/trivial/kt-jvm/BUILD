load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_binary", "kt_jvm_test")
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_kotlin_library")

uniffi_kotlin_library(
    name = "trivial_kt",
    library = "//:trivial",
)

kt_jvm_binary(
    name = "trivial_bin",
    srcs = ["main.kt"],
    main_class = "trivial.Main",
    deps = [":trivial_kt"],
)

kt_jvm_test(
    name = "trivial_kt_test",
    srcs = ["main.kt"],
    main_class = "trivial.Main",
    deps = [":trivial_kt"],
)

build_test(
    name = "trivial_kt_build_test",
    targets = [
        "trivial_kt.jar",
    ],
)

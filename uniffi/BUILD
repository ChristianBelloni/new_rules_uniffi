load("@stardoc//stardoc:stardoc.bzl", "stardoc")

stardoc(
    name = "docs",
    out = "rules_uniffi.md",
    input = "defs.bzl",
    symbol_names = [
        "uniffi_library",
        "uniffi_kotlin_library",
        "uniffi_android_library",
        "uniffi_swift_library",
    ],
    deps = [
        "@rules_uniffi//uniffi/private",
    ],
)

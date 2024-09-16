load("@rules_rust//rust:rust_common.bzl", "CrateInfo")

_rust_uniffi_library_impl(ctx):
    pass


rust_uniffi_library = rule(
    implementation = _rust_uniffi_library_impl,
    attrs = {
        "library": attr.label(provider = [CrateInfo])
    }
)

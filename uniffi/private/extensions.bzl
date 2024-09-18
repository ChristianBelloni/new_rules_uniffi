load("@rules_uniffi//uniffi/3rdparty/crates:defs.bzl", "crate_repositories")

def _internal_deps_impl(_module_ctx):
    crate_repositories()

i = module_extension(
    doc = "",
    implementation = _internal_deps_impl,
)

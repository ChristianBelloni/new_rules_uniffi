load("//uniffi:repositories.bzl", "rules_uniffi_dependencies")

def _internal_deps_impl(_module_ctx):
    rules_uniffi_dependencies()

i = module_extension(
    doc = "",
    implementation = _internal_deps_impl,
)

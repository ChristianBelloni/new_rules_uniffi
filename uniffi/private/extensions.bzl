load("//uniffi:repositories.bzl", "rules_uniffi_dependencies")
load("//uniffi:setup.bzl", "rules_uniffi_setup")

def _internal_deps_impl(_module_ctx):
    rules_uniffi_dependencies()
    rules_uniffi_setup()

i = module_extension(
    doc = "",
    implementation = _internal_deps_impl,
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@rules_uniffi//uniffi/3rdparty/crates:crates.bzl", "crate_repositories")

def rules_uniffi_setup():
    crate_repositories()

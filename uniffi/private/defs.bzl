load("@bazel_skylib//lib:structs.bzl", "structs")
load("@rules_android//android:library.bzl", "android_library")
load("@rules_cc//cc:defs.bzl", "cc_import")
load("@rules_kotlin//kotlin:android.bzl", "kt_android_library")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")

# load("//uniffi/private/generate:defs.bzl", "rust_uniffi_library_tool_impl")
load("@rules_rust//rust:rust_common.bzl", "CrateInfo")
load("@rules_rust//rust/private:rustc.bzl", "rustc_compile_action")
load(
    "@rules_rust//rust/private:utils.bzl",
    "compute_crate_name",
    "find_toolchain",
)
load(":rust.bzl", "RUST_ATTRS", "rust_library_common")

RUNNER = """
{RUNNER} generate --library {LIB} --language kotlin --out-dir {OUT}
"""

UniffiInfo = provider(doc = "", fields = {
    "kotlin_srcs": "Kotlin sources",
    "shared_lib": "Shared library",
    "swift_srcs": "Swift sources",
    "static_lib": "Static library",
})

def _rust_uniffi_library_impl(ctx):
    staticlib_files = rust_library_common(ctx, "staticlib")
    staticlib = staticlib_files[0].files.to_list()[0]

    rlib_files = rust_library_common(ctx, "rlib")

    dylib_files = rust_library_common(ctx, "cdylib")
    dylib = dylib_files[0].files.to_list()[0]

    toolchain = find_toolchain(ctx)

    crate_name = compute_crate_name(ctx.workspace_name, ctx.label, toolchain, ctx.attr.crate_name)

    out_kotlin = ctx.actions.declare_file("dir_kt/uniffi/{}/{}.kt".format(crate_name, crate_name))
    out_swift = ctx.actions.declare_file("dir_swift/{}.swift".format(crate_name))

    _compute_kotlin(ctx, dylib, ctx.executable._generate_tool, out_kotlin)
    _compute_swift(ctx, staticlib, ctx.executable._generate_tool, out_swift)

    uniffi = UniffiInfo(
        kotlin_srcs = depset([out_kotlin]),
        shared_lib = depset([dylib]),
        swift_srcs = depset([out_swift]),
        static_lib = depset([staticlib]),
    )

    rlib_files.append(uniffi)

    return rlib_files

def _compute_kotlin(ctx, dylib, tool, out):
    out_dir = out.dirname.split("/")
    out_dir.pop()
    out_dir.pop()

    out_dir = "/".join(out_dir)

    ctx.actions.run(
        inputs = [dylib],
        executable = tool,
        arguments = ["generate", "--library", dylib.path, "--out-dir", out_dir, "--language", "kotlin"],
        outputs = [out],
        mnemonic = "UniffiGenerate",
    )

def _compute_swift(ctx, staticlib, tool, out):
    out_dir = out.dirname
    ctx.actions.run(
        inputs = [staticlib],
        executable = tool,
        arguments = ["generate", "--library", staticlib.path, "--out-dir", out_dir, "--language", "swift"],
        outputs = [out],
        mnemonic = "UniffiGenerate",
    )

def rust_kotlin_library(name, library):
    extract_kt_sources(
        name = "_" + name + "_srcs",
        lib = library,
    )
    extract_dylib(
        name = "_dylib_" + name,
        lib = library,
    )
    kt_jvm_library(
        name = name,
        srcs = ["_" + name + "_srcs"],
        deps = [Label("@rules_uniffi//uniffi/3rdparty:jna_jar")],
        data = ["_dylib_" + name],
    )

def rust_kotlin_android_library(name, library):
    extract_kt_sources(
        name = "_" + name + "_srcs",
        lib = library,
    )
    kt_android_library(
        name = "_" + name,
        srcs = ["_" + name + "_srcs"],
        deps = [Label("@rules_uniffi//uniffi/3rdparty:jna_aar")],
    )
    extract_dylib(
        name = "_dylib_" + name,
        lib = library,
    )
    cc_import(
        name = "_" + name + "_shim",
        shared_library = "_dylib_" + name,
    )
    android_library(
        name = name,
        exports = ["_" + name, "_" + name + "_shim"],
    )

def _extract_dylib_impl(ctx):
    files = ctx.attr.lib[UniffiInfo]

    return DefaultInfo(
        files = files.shared_lib,
    )

extract_dylib = rule(
    implementation = _extract_dylib_impl,
    attrs = {
        "lib": attr.label(providers = [UniffiInfo]),
    },
)

def _extract_kt_sources_impl(ctx):
    files = ctx.attr.lib[UniffiInfo]

    return DefaultInfo(
        files = files.kotlin_srcs,
    )

extract_kt_sources = rule(
    implementation = _extract_kt_sources_impl,
    attrs = {
        "lib": attr.label(providers = [UniffiInfo]),
    },
)

rust_uniffi_library = rule(
    implementation = _rust_uniffi_library_impl,
    attrs = {
        "_generate_tool": attr.label(default = Label("@rules_uniffi//uniffi/private/generate:generate_bin"), executable = True, cfg = "exec"),
    } | RUST_ATTRS,
    toolchains = [
        str(Label("@rules_rust//rust:toolchain_type")),
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    fragments = ["cpp"],
)

""" Bazel rules for Mozilla's uniffi framework"""

load("@build_bazel_rules_swift//swift:swift.bzl", _swift_library = "swift_library")
load("@build_bazel_rules_swift//swift:swift_interop_hint.bzl", _swift_interop_hint = "swift_interop_hint")
load("@rules_android//rules:rules.bzl", _android_library = "android_library")
load("@rules_kotlin//kotlin:jvm.bzl", _kt_jvm_library = "kt_jvm_library")
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
    "swift_header": "Swift header",
    "swift_modulemap": "Swift modulemap",
})

def _uniffi_library_impl(ctx):
    name = ctx.attr.name
    staticlib_files = rust_library_common(ctx, "staticlib")
    staticlib = staticlib_files[0].files.to_list()[0]

    rlib_files = rust_library_common(ctx, "rlib")

    dylib_files = rust_library_common(ctx, "cdylib")
    dylib = dylib_files[0].files.to_list()[0]

    toolchain = find_toolchain(ctx)

    crate_name = compute_crate_name(ctx.workspace_name, ctx.label, toolchain, ctx.attr.crate_name)

    uniffi_toml = ctx.actions.declare_file("uniffi.toml")

    ctx.actions.write(
        content = """
        [bindings.kotlin]
        package_name = "{PACKAGE_NAME}"
        """.replace("{PACKAGE_NAME}", ctx.attr.package_name),
        output = uniffi_toml,
    )

    dirs = "/".join(ctx.attr.package_name.split("."))

    out_kotlin = ctx.actions.declare_file(name + "/dir_kt/{}/{}.kt".format(dirs, crate_name))
    out_swift = ctx.actions.declare_file(name + "/dir_swift/{}.swift".format(crate_name))
    out_swift_header = ctx.actions.declare_file(name + "/dir_swift/{}FFI.h".format(crate_name))
    out_swift_modulemap = ctx.actions.declare_file(name + "/dir_swift/{}FFI.modulemap".format(crate_name))

    out_dir_kotlin = out_kotlin.path.split(name + "/dir_kt")[0] + name + "/dir_kt"
    _compute_kotlin(ctx, out_dir_kotlin, dylib, ctx.executable._generate_tool, out_kotlin, uniffi_toml)
    _compute_swift(ctx, staticlib, ctx.executable._generate_tool, out_swift, out_swift_header, out_swift_modulemap)

    uniffi = UniffiInfo(
        kotlin_srcs = depset([out_kotlin]),
        shared_lib = depset([dylib]),
        swift_srcs = depset([out_swift]),
        static_lib = depset([staticlib]),
        swift_header = depset([out_swift_header]),
        swift_modulemap = depset([out_swift_modulemap]),
    )

    rlib_files.append(uniffi)

    return rlib_files

def _compute_kotlin(ctx, out_dir, dylib, tool, out, config):
    ctx.actions.run(
        inputs = [dylib, config],
        executable = tool,
        arguments = ["generate", "--config", config.path, "--library", dylib.path, "--out-dir", out_dir, "--language", "kotlin"],
        outputs = [out],
        mnemonic = "UniffiGenerate",
    )

def _compute_swift(ctx, staticlib, tool, out, out_header, out_modulemap):
    out_dir = out.dirname
    ctx.actions.run(
        inputs = [staticlib],
        executable = tool,
        arguments = ["generate", "--library", staticlib.path, "--out-dir", out_dir, "--language", "swift"],
        outputs = [out, out_header, out_modulemap],
        mnemonic = "UniffiGenerate",
    )

def uniffi_kotlin_library(name, library):
    extract_kt_sources(
        name = "_" + name + "_srcs",
        lib = library,
    )
    extract_dylib(
        name = "_dylib_" + name,
        lib = library,
    )
    _kt_jvm_library(
        name = name,
        srcs = ["_" + name + "_srcs"],
        deps = [Label("@rules_uniffi//uniffi/3rdparty:jna_jar")],
        data = ["_dylib_" + name],
    )

def uniffi_android_library(name, library):
    """Creates an android kotlin library from a uniffi library

    Extract a kt_android_library from a uniffi_library definition

    Args:
        name: Unique name for the generated kt_android_library
        library: Uniffi library generated from uniffi_library
    """
    extract_kt_sources(
        name = "_" + name + "_srcs",
        lib = library,
    )
    extract_dylib(
        name = "_dylib_" + name,
        lib = library,
    )
    _kt_jvm_library(
        name = "_" + name,
        srcs = ["_" + name + "_srcs"],
        deps = [Label("@rules_uniffi//uniffi/3rdparty:jna_aar")],
    )
    native.cc_import(
        name = "_" + name + "_shim",
        shared_library = "_dylib_" + name,
    )
    _android_library(
        name = name,
        exports = ["_" + name, "_" + name + "_shim"],
    )

def uniffi_swift_library(name, library, module_name = None):
    """Creates a swift library from a uniffi library

    Extract a swift_library from a uniffi_library definition

    Args:
        name: Unique name for the generated swift_library
        library: Uniffi library generated from uniffi_library
        module_name: Generated swift module name, (defaults to name)
    """
    extract_swift_sources(
        name = "_" + name + "_srcs",
        lib = library,
    )
    extract_staticlib(
        name = "_staticlib_" + name,
        lib = library,
    )

    extract_swift_modulemap(
        name = "_" + name + "_modulemap",
        lib = library,
    )

    if (module_name == None):
        module_name = name

    _swift_interop_hint(
        name = "_interop_hint_" + name,
        module_name = module_name,
        module_map = "_" + name + "_modulemap",
    )

    native.cc_import(
        name = "_" + name + "_shim",
        static_library = "_staticlib_" + name,
        aspect_hints = ["_interop_hint_" + name],
    )
    _swift_library(
        name = name,
        srcs = ["_" + name + "_srcs"],
        deps = ["_" + name + "_shim"],
        module_name = module_name,
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

def _extract_staticlib_impl(ctx):
    files = ctx.attr.lib[UniffiInfo]

    return DefaultInfo(
        files = files.static_lib,
    )

extract_staticlib = rule(
    implementation = _extract_staticlib_impl,
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

def _extract_swift_sources_impl(ctx):
    files = ctx.attr.lib[UniffiInfo]
    return DefaultInfo(
        files = files.swift_srcs,
    )

extract_swift_sources = rule(
    implementation = _extract_swift_sources_impl,
    attrs = {
        "lib": attr.label(providers = [UniffiInfo]),
    },
)

def _extract_swift_header_impl(ctx):
    files = ctx.attr.lib[UniffiInfo]
    return DefaultInfo(
        files = files.swift_header,
    )

extract_swift_header = rule(
    implementation = _extract_swift_header_impl,
    attrs = {
        "lib": attr.label(providers = [UniffiInfo]),
    },
)

def _extract_swift_modulemap_impl(ctx):
    files = ctx.attr.lib[UniffiInfo]
    return DefaultInfo(
        files = files.swift_modulemap,
    )

extract_swift_modulemap = rule(
    implementation = _extract_swift_modulemap_impl,
    attrs = {
        "lib": attr.label(providers = [UniffiInfo]),
    },
)

uniffi_library = rule(
    implementation = _uniffi_library_impl,
    attrs = {
        "package_name": attr.string(default = "uniffi", doc = "Package name applied for kotlin bindings"),
        "_generate_tool": attr.label(default = Label("@rules_uniffi//uniffi/private/generate:generate_bin"), executable = True, cfg = "exec"),
    } | RUST_ATTRS,
    toolchains = [
        str(Label("@rules_rust//rust:toolchain_type")),
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    fragments = ["cpp"],
)

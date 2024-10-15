""" Bazel rules for Mozilla's uniffi framework"""

load("@build_bazel_rules_swift//swift:swift.bzl", _swift_library = "swift_library")
load("@build_bazel_rules_swift//swift:swift_interop_hint.bzl", _swift_interop_hint = "swift_interop_hint")
load("@rules_kotlin//kotlin:jvm.bzl", _kt_jvm_library = "kt_jvm_library")
load(":kotlin.bzl", _kt_android_library = "kt_android_library")
load("@rules_uniffi//uniffi/3rdparty:defs.bzl", "KOTLIN_DEPS")
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
    "name": "name",
    "kotlin_srcs": "Kotlin sources",
    "shared_lib": "Shared library",
    "swift_srcs": "Swift sources",
    "static_lib": "Static library",
    "swift_header": "Swift header",
    "swift_modulemap": "Swift modulemap",
    "deps": "Uniffi deps",
})

def uniffi_library(**kwargs):
    _swift_interop_hint(
        name = "_interop_swift_" + kwargs.get("name"),
    )
    _uniffi_library(aspect_hints = ["_interop_swift_" + kwargs.get("name")], alwayslink = True, **kwargs)

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
        """,
        output = uniffi_toml,
    )

    uniffi_deps = []

    for dep in ctx.attr.deps:
        if UniffiInfo in dep:
            uniffi_deps.append(dep[UniffiInfo])

    deps_module_maps = [crate_name]
    deps_headers = []

    for dep in uniffi_deps:
        header = dep.swift_header.to_list()[0]
        deps_module_maps.append(dep.name)
        out_swift_header = ctx.actions.declare_file(name + "/dir_swift/{}FFI.h".format(dep.name))
        ctx.actions.run_shell(
            inputs = [header],
            outputs = [out_swift_header],
            command = "cp {} {}".format(header.path, out_swift_header.path),
        )
        deps_headers.append(out_swift_header)

    out_kotlin = ctx.actions.declare_file(name + "/dir_kt/uniffi/{}/{}.kt".format(crate_name, crate_name))
    out_swift = ctx.actions.declare_file(name + "/dir_swift/{}.swift".format(crate_name))
    out_swift_header = ctx.actions.declare_file(name + "/dir_swift/{}FFI.h".format(crate_name))
    out_swift_modulemap = ctx.actions.declare_file(name + "/dir_swift/{}FFI.modulemap".format(crate_name))

    out_dir_kotlin = out_kotlin.path.split(name + "/dir_kt")[0] + name + "/dir_kt"
    _compute_kotlin(ctx, out_dir_kotlin, dylib, ctx.executable._generate_tool, out_kotlin, uniffi_toml)
    _compute_swift(ctx, deps_module_maps, dylib, ctx.executable._generate_tool, out_swift, out_swift_header, out_swift_modulemap)

    out_kotlin = [out_kotlin]
    out_swift = out_swift
    out_swift_header = [out_swift_header] + deps_headers
    out_swift_modulemap = [out_swift_modulemap]

    dylib = [dylib]

    for dep in uniffi_deps:
        for lib in dep.shared_lib.to_list():
            out = ctx.actions.declare_file("libs/" + lib.basename)
            ctx.actions.run_shell(
                inputs = [lib],
                outputs = [out],
                command = "cp {} {}".format(lib.path, out.path),
            )
            dylib.append(out)

    uniffi = UniffiInfo(
        name = crate_name,
        kotlin_srcs = depset(out_kotlin),
        shared_lib = depset(dylib),
        swift_srcs = depset([out_swift]),
        static_lib = depset([staticlib]),
        swift_header = depset(out_swift_header),
        swift_modulemap = depset(out_swift_modulemap),
        deps = uniffi_deps,
    )

    rlib_files.append(uniffi)

    return rlib_files

_uniffi_library = rule(
    implementation = _uniffi_library_impl,
    attrs = {
        "workspace_toml": attr.label(allow_single_file = True),
        "_generate_tool": attr.label(default = Label("@rules_uniffi//uniffi/private/generate:generate_bin"), executable = True, cfg = "exec"),
    } | RUST_ATTRS,
    toolchains = [
        str(Label("@rules_rust//rust:toolchain_type")),
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    fragments = ["cpp"],
)

def _compute_kotlin(ctx, out_dir, dylib, tool, out, config):
    ctx.actions.run(
        inputs = [dylib, config],
        executable = tool,
        arguments = ["generate", "--config", config.path, "--library", dylib.path, "--out-dir", out_dir, "--language", "kotlin"],
        outputs = [out],
        mnemonic = "UniffiGenerate",
    )

def _compute_swift(ctx, crates, staticlib, tool, out, out_header, out_modulemap):
    inputs = [staticlib]
    out_dir = out.dirname
    ctx.actions.run(
        inputs = inputs,
        executable = tool,
        arguments = ["generate", "--library", staticlib.path, "--out-dir", out_dir, "--language", "swift"],
        outputs = [out, out_header, out_modulemap],
        mnemonic = "UniffiGenerate",
    )

    new_modulemap = ctx.actions.declare_file(out_modulemap.dirname + "Gen{}FFI.modulemap".format(ctx.attr.name))

    formats = []
    for c in crates:
        formats.append("""module {}FFI {{
    header "{}FFI.h"
    export *
}}""".format(c, c))

    ctx.actions.write(
        content = "\n".join(formats),
        output = new_modulemap,
    )

def uniffi_kotlin_library(name, library, package_name = None):
    if (package_name == None):
        package_name = name

    extract_kt_sources(
        name = "_" + name + "_srcs",
        lib = library,
        package_name = package_name,
    )
    extract_dylib(
        name = "_dylib_" + name,
        lib = library,
    )

    _kt_jvm_library(
        name = name,
        srcs = ["_" + name + "_srcs"],
        deps = KOTLIN_DEPS,
        data = ["_dylib_" + name],
    )

def uniffi_android_library(name, library, package_name = None):
    """Creates an android kotlin library from a uniffi library

    Extract a kt_android_library from a uniffi_library definition

    Args:
        name: Unique name for the generated kt_android_library
        library: Uniffi library generated from uniffi_library
    """

    if (package_name == None):
        package_name = name

    extract_kt_sources(
        name = "_" + name + "_srcs",
        lib = library,
        package_name = package_name,
    )

    extract_dylib(
        name = "_dylib_" + name,
        lib = library,
    )

    native.cc_import(
      name = "_shim_" + name,
      shared_library = "_dylib_" + name,
    )

    _kt_android_library(
        name = name,
        srcs = ["_" + name + "_srcs"],
        deps = KOTLIN_DEPS,
        exports = KOTLIN_DEPS + ["_shim_" + name],
    )

def uniffi_swift_library(name, library, module_name = None):
    """Creates a swift library from a uniffi library

    Extract a swift_library from a uniffi_library definition

    Args:
        name: Unique name for the generated swift_library
        library: Uniffi library generated from uniffi_library
        module_name: Generated swift module name, (defaults to name)
    """

    if (module_name == None):
        module_name = name

    extract_swift_sources(
        name = "_" + name + "_srcs",
        lib = library,
    )

    extract_staticlib(
        name = "_staticlib_" + name,
        lib = library,
        module_name = module_name,
    )

    extract_swift_modulemap(
        name = "_" + name + "_modulemap",
        lib = library,
    )

    extract_swift_header(
        name = "_" + name + "_headers",
        lib = library,
    )

    _swift_interop_hint(
        name = "_" + name + "_hint",
        module_map = "_" + name + "_modulemap",
        module_name = module_name,
    )

    native.cc_import(
        name = "_" + name + "_shim",
        hdrs = ["_" + name + "_headers"],
        static_library = "_staticlib_" + name,
        aspect_hints = ["_" + name + "_hint"],
        alwayslink = True,
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
    cc_info = ctx.attr.lib[CcInfo]

    return [DefaultInfo(
        files = files.static_lib,
    ), cc_info]

extract_staticlib = rule(
    implementation = _extract_staticlib_impl,
    attrs = {
        "lib": attr.label(providers = [UniffiInfo, CcInfo]),
        "module_name": attr.string(),
    },
)

def _extract_kt_sources_impl(ctx):
    files = ctx.attr.lib[UniffiInfo]

    lib = ctx.actions.declare_file("lib" + files.name + ".dylib")

    ctx.actions.run_shell(
        inputs = files.shared_lib.to_list(),
        outputs = [lib],
        command = "cp {} {}".format(files.shared_lib.to_list()[0].path, lib.path),
    )

    input_kts = [(files.name, files.kotlin_srcs.to_list()[0])]

    for dep in files.deps:
        input_kts.append((dep.name, dep.kotlin_srcs.to_list()[0]))

    out_kts = []

    for (name, kt) in input_kts:
        out_kt = ctx.actions.declare_file(ctx.attr.name + kt.basename)

        ctx.actions.run_shell(
            inputs = [kt],
            command = "sed '6s/.*/package {}/' {} > {}".format(ctx.attr.package_name + "." + name + ";", kt.path, out_kt.path),
            outputs = [out_kt],
        )

        out_kts.append(out_kt)

    return DefaultInfo(
        files = depset(out_kts + [lib]),
    )

extract_kt_sources = rule(
    implementation = _extract_kt_sources_impl,
    attrs = {
        "lib": attr.label(providers = [UniffiInfo]),
        "package_name": attr.string(mandatory = True),
    },
)

def _extract_swift_sources_impl(ctx):
    info = ctx.attr.lib[UniffiInfo]
    files = info.swift_srcs.to_list()
    for dep in info.deps:
        files += dep.swift_srcs.to_list()

    return DefaultInfo(
        files = depset(files),
    )

extract_swift_sources = rule(
    implementation = _extract_swift_sources_impl,
    attrs = {
        "lib": attr.label(providers = [UniffiInfo]),
    },
)

def _extract_swift_header_impl(ctx):
    info = ctx.attr.lib[UniffiInfo]

    return DefaultInfo(
        files = info.swift_header,
    )

extract_swift_header = rule(
    implementation = _extract_swift_header_impl,
    attrs = {
        "lib": attr.label(providers = [UniffiInfo]),
    },
)

def _extract_swift_modulemap_impl(ctx):
    info = ctx.attr.lib[UniffiInfo]

    return DefaultInfo(
        files = info.swift_modulemap,
    )

extract_swift_modulemap = rule(
    implementation = _extract_swift_modulemap_impl,
    attrs = {
        "lib": attr.label(providers = [UniffiInfo]),
    },
)

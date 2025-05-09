load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_rust//rust:defs.bzl", "rust_common")
load("@rules_rust//rust/private:rustc.bzl", "rustc_compile_action")
load(
    "@rules_rust//rust/private:utils.bzl",
    "can_build_metadata",
    "compute_crate_name",
    "crate_root_src",
    "dedent",
    "determine_lib_name",
    "determine_output_hash",
    "find_toolchain",
    "generate_output_diagnostics",
    "get_edition",
    "get_import_macro_deps",
    "transform_deps",
    "transform_sources",
)

RUSTC_ATTRS = {
    "_cc_toolchain": attr.label(
        doc = (
            "In order to use find_cc_toolchain, your rule has to depend " +
            "on C++ toolchain. See `@rules_cc//cc:find_cc_toolchain.bzl` " +
            "docs for details."
        ),
        default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
    ),
    "_error_format": attr.label(
        default = Label("@rules_rust//:error_format"),
    ),
    "_extra_exec_rustc_flag": attr.label(
        default = Label("@rules_rust//:extra_exec_rustc_flag"),
    ),
    "_extra_exec_rustc_flags": attr.label(
        default = Label("@rules_rust//:extra_exec_rustc_flags"),
    ),
    "_extra_rustc_flag": attr.label(
        default = Label("@rules_rust//:extra_rustc_flag"),
    ),
    "_extra_rustc_flags": attr.label(
        default = Label("@rules_rust//:extra_rustc_flags"),
    ),
    "_is_proc_macro_dep": attr.label(
        default = Label("@rules_rust//rust/private:is_proc_macro_dep"),
    ),
    "_is_proc_macro_dep_enabled": attr.label(
        default = Label("@rules_rust//rust/private:is_proc_macro_dep_enabled"),
    ),
    "_per_crate_rustc_flag": attr.label(
        default = Label("@rules_rust//:experimental_per_crate_rustc_flag"),
    ),
    "_process_wrapper": attr.label(
        doc = "A process wrapper for running rustc on all platforms.",
        default = Label("@rules_rust//util/process_wrapper"),
        executable = True,
        allow_single_file = True,
        cfg = "exec",
    ),
    "_rustc_output_diagnostics": attr.label(
        default = Label("@rules_rust//:rustc_output_diagnostics"),
    ),
}

RUST_ATTRS = {
    "aliases": attr.label_keyed_string_dict(
        doc = dedent("""\
            Remap crates to a new name or moniker for linkage to this target

            These are other `rust_library` targets and will be presented as the new name given.
        """),
    ),
    "alwayslink": attr.bool(
        doc = dedent("""\
            If 1, any binary that depends (directly or indirectly) on this library
            will link in all the object files even if some contain no symbols referenced by the binary.

            This attribute is used by the C++ Starlark API when passing CcInfo providers.
        """),
        default = False,
    ),
    "compile_data": attr.label_list(
        doc = dedent("""\
            List of files used by this rule at compile time.

            This attribute can be used to specify any data files that are embedded into
            the library, such as via the
            [`include_str!`](https://doc.rust-lang.org/std/macro.include_str!.html)
            macro.
        """),
        allow_files = True,
    ),
    "crate_features": attr.string_list(
        doc = dedent("""\
            List of features to enable for this crate.

            Features are defined in the code using the `#[cfg(feature = "foo")]`
            configuration option. The features listed here will be passed to `rustc`
            with `--cfg feature="${feature_name}"` flags.
        """),
    ),
    "crate_name": attr.string(
        doc = dedent("""\
            Crate name to use for this target.

            This must be a valid Rust identifier, i.e. it may contain only alphanumeric characters and underscores.
            Defaults to the target name, with any hyphens replaced by underscores.
        """),
    ),
    "crate_root": attr.label(
        doc = dedent("""\
            The file that will be passed to `rustc` to be used for building this crate.

            If `crate_root` is not set, then this rule will look for a `lib.rs` file (or `main.rs` for rust_binary)
            or the single file in `srcs` if `srcs` contains only one file.
        """),
        allow_single_file = [".rs"],
    ),
    "data": attr.label_list(
        doc = dedent("""\
            List of files used by this rule at compile time and runtime.

            If including data at compile time with include_str!() and similar,
            prefer `compile_data` over `data`, to prevent the data also being included
            in the runfiles.
        """),
        allow_files = True,
    ),
    "deps": attr.label_list(
        doc = dedent("""\
            List of other libraries to be linked to this library target.

            These can be either other `rust_library` targets or `cc_library` targets if
            linking a native library.
        """),
    ),
    "edition": attr.string(
        doc = "The rust edition to use for this crate. Defaults to the edition specified in the rust_toolchain.",
    ),
    # Previously `proc_macro_deps` were a part of `deps`, and then proc_macro_host_transition was
    # used into cfg="host" using `@local_config_platform//:host`.
    # This fails for remote execution, which needs cfg="exec", and there isn't anything like
    # `@local_config_platform//:exec` exposed.
    "proc_macro_deps": attr.label_list(
        doc = dedent("""\
            List of `rust_proc_macro` targets used to help build this library target.
        """),
        cfg = "exec",
        providers = [rust_common.crate_info],
    ),
    "rustc_env": attr.string_dict(
        doc = dedent("""\
            Dictionary of additional `"key": "value"` environment variables to set for rustc.

            rust_test()/rust_binary() rules can use $(rootpath //package:target) to pass in the
            location of a generated file or external tool. Cargo build scripts that wish to
            expand locations should use cargo_build_script()'s build_script_env argument instead,
            as build scripts are run in a different environment - see cargo_build_script()'s
            documentation for more.
        """),
    ),
    "rustc_env_files": attr.label_list(
        doc = dedent("""\
            Files containing additional environment variables to set for rustc.

            These files should  contain a single variable per line, of format
            `NAME=value`, and newlines may be included in a value by ending a
            line with a trailing back-slash (`\\\\`).

            The order that these files will be processed is unspecified, so
            multiple definitions of a particular variable are discouraged.

            Note that the variables here are subject to
            [workspace status](https://docs.bazel.build/versions/main/user-manual.html#workspace_status)
            stamping should the `stamp` attribute be enabled. Stamp variables
            should be wrapped in brackets in order to be resolved. E.g.
            `NAME={WORKSPACE_STATUS_VARIABLE}`.
        """),
        allow_files = True,
    ),
    "rustc_flags": attr.string_list(
        doc = dedent("""\
            List of compiler flags passed to `rustc`.

            These strings are subject to Make variable expansion for predefined
            source/output path variables like `$location`, `$execpath`, and
            `$rootpath`. This expansion is useful if you wish to pass a generated
            file of arguments to rustc: `@$(location //package:target)`.
        """),
    ),
    # TODO(stardoc): How do we provide additional documentation to an inherited attribute?
    # "name": attr.string(
    #     doc = "This name will also be used as the name of the crate built by this rule.",
    # `),
    "srcs": attr.label_list(
        doc = dedent("""\
            List of Rust `.rs` source files used to build the library.

            If `srcs` contains more than one file, then there must be a file either
            named `lib.rs`. Otherwise, `crate_root` must be set to the source file that
            is the root of the crate to be passed to rustc to build this crate.
        """),
        allow_files = [".rs"],
        # Allow use of --compile_one_dependency with rust targets. Support for this feature for
        # non-builtin rulesets is undocumented outside of the bazel source:
        # https://github.com/bazelbuild/bazel/blob/7.1.1/src/main/java/com/google/devtools/build/lib/packages/Attribute.java#L102
        flags = ["DIRECT_COMPILE_TIME_INPUT"],
    ),
    "version": attr.string(
        doc = "A version to inject in the cargo environment variable.",
        default = "0.0.0",
    ),
    "_stamp_flag": attr.label(
        doc = "A setting used to determine whether or not the `--stamp` flag is enabled",
        default = Label("@rules_rust//rust/private:stamp"),
    ),
} | RUSTC_ATTRS

def rust_library_common(ctx, crate_type):
    """The common implementation of the library-like rules.

    Args:
        ctx (ctx): The rule's context object
        crate_type (String): one of lib|rlib|dylib|staticlib|cdylib|proc-macro

    Returns:
        list: A list of providers. See `rustc_compile_action`
    """
    #_assert_no_deprecated_attributes(ctx)
    #_assert_correct_dep_mapping(ctx)

    toolchain = find_toolchain(ctx)

    crate_name = compute_crate_name(ctx.workspace_name, ctx.label, toolchain, ctx.attr.name)

    crate_root = getattr(ctx.file, "crate_root", None)
    if not crate_root:
        crate_root = crate_root_src(ctx.attr.name, ctx.attr.crate_name, ctx.files.srcs, crate_type)
    srcs, compile_data, crate_root = transform_sources(ctx, ctx.files.srcs, ctx.files.compile_data, crate_root)

    # Determine unique hash for this rlib.
    # Note that we don't include a hash for `cdylib` and `staticlib` since they are meant to be consumed externally
    # and having a deterministic name is important since it ends up embedded in the executable. This is problematic
    # when one needs to include the library with a specific filename into a larger application.
    # (see https://github.com/bazelbuild/rules_rust/issues/405#issuecomment-993089889 for more details)
    if crate_type in ["cdylib", "staticlib"]:
        output_hash = None
    else:
        output_hash = determine_output_hash(crate_root, ctx.label)

    rust_lib_name = determine_lib_name(
        crate_name,
        crate_type,
        toolchain,
        output_hash,
    )
    rust_lib = ctx.actions.declare_file(rust_lib_name)
    rust_metadata = None
    rustc_rmeta_output = None
    if can_build_metadata(toolchain, ctx, crate_type) and not ctx.attr.disable_pipelining:
        rust_metadata = ctx.actions.declare_file(
            paths.replace_extension(rust_lib_name, ".rmeta"),
            sibling = rust_lib,
        )
        rustc_rmeta_output = generate_output_diagnostics(ctx, rust_metadata)

    deps = transform_deps(ctx.attr.deps)
    proc_macro_deps = transform_deps(ctx.attr.proc_macro_deps + get_import_macro_deps(ctx))

    return rustc_compile_action(
        ctx = ctx,
        attr = ctx.attr,
        toolchain = toolchain,
        output_hash = output_hash,
        crate_info_dict = dict(
            name = crate_name,
            type = crate_type,
            root = crate_root,
            srcs = depset(srcs),
            deps = depset(deps),
            proc_macro_deps = depset(proc_macro_deps),
            aliases = ctx.attr.aliases,
            output = rust_lib,
            rustc_output = generate_output_diagnostics(ctx, rust_lib),
            metadata = rust_metadata,
            rustc_rmeta_output = rustc_rmeta_output,
            edition = get_edition(ctx.attr, toolchain, ctx.label),
            rustc_env = ctx.attr.rustc_env,
            rustc_env_files = ctx.files.rustc_env_files,
            is_test = False,
            data = depset(ctx.files.data),
            compile_data = depset(ctx.files.compile_data),
            compile_data_targets = depset(ctx.attr.compile_data),
            owner = ctx.label,
        ),
    )

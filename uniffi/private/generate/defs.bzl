load("@rules_rust//rust:rust_common.bzl", "CrateInfo")

RUNNER = """
{RUNNER} generate --library {LIB} --language kotlin --out-dir {OUT}
"""

def rust_uniffi_library_tool_impl(ctx):
    crate_info = ctx.attr.library[CcInfo]
    library = crate_info.linking_context.linker_inputs.to_list()[0].libraries[0].dynamic_library

    # output = ctx.actions.declare_file("temp.log")

    runner = ctx.actions.declare_file("_runner.sh")

    out_dir = ctx.actions.declare_directory("out")

    ctx.actions.run_shell(
        command = "mkdir %s" % out_dir.path,
        outputs = [out_dir],
    )

    ctx.actions.write(
        content = RUNNER.replace("{RUNNER}", ctx.executable._generate_tool.path).replace("{LIB}", library.path).replace("{OUT}", out_dir.path),
        output = runner,
    )

    return [DefaultInfo(
        files = depset([library, ctx.executable._generate_tool, runner]),
        # runfiles = ctx.runfiles(files = [library]),
        data_runfiles = ctx.runfiles(files = [library, runner]),
        default_runfiles = None,
        executable = runner,
    )]

rust_uniffi_library_tool = rule(
    implementation = rust_uniffi_library_tool_impl,
    attrs = {
        "library": attr.label(providers = [CcInfo]),
        "_generate_tool": attr.label(default = "@rules_uniffi//uniffi/private/generate:generate_bin", executable = True, cfg = "exec"),
    },
    executable = True,
)

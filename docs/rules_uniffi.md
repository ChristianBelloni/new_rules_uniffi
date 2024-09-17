<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="uniffi_library"></a>

## uniffi_library

<pre>
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_library")

uniffi_library(<a href="#uniffi_library-name">name</a>, <a href="#uniffi_library-deps">deps</a>, <a href="#uniffi_library-srcs">srcs</a>, <a href="#uniffi_library-data">data</a>, <a href="#uniffi_library-aliases">aliases</a>, <a href="#uniffi_library-alwayslink">alwayslink</a>, <a href="#uniffi_library-compile_data">compile_data</a>, <a href="#uniffi_library-crate_features">crate_features</a>,
               <a href="#uniffi_library-crate_name">crate_name</a>, <a href="#uniffi_library-crate_root">crate_root</a>, <a href="#uniffi_library-edition">edition</a>, <a href="#uniffi_library-package_name">package_name</a>, <a href="#uniffi_library-proc_macro_deps">proc_macro_deps</a>, <a href="#uniffi_library-rustc_env">rustc_env</a>,
               <a href="#uniffi_library-rustc_env_files">rustc_env_files</a>, <a href="#uniffi_library-rustc_flags">rustc_flags</a>, <a href="#uniffi_library-version">version</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="uniffi_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="uniffi_library-deps"></a>deps |  List of other libraries to be linked to this library target.<br><br>These can be either other `rust_library` targets or `cc_library` targets if linking a native library.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="uniffi_library-srcs"></a>srcs |  List of Rust `.rs` source files used to build the library.<br><br>If `srcs` contains more than one file, then there must be a file either named `lib.rs`. Otherwise, `crate_root` must be set to the source file that is the root of the crate to be passed to rustc to build this crate.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="uniffi_library-data"></a>data |  List of files used by this rule at compile time and runtime.<br><br>If including data at compile time with include_str!() and similar, prefer `compile_data` over `data`, to prevent the data also being included in the runfiles.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="uniffi_library-aliases"></a>aliases |  Remap crates to a new name or moniker for linkage to this target<br><br>These are other `rust_library` targets and will be presented as the new name given.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |
| <a id="uniffi_library-alwayslink"></a>alwayslink |  If 1, any binary that depends (directly or indirectly) on this library will link in all the object files even if some contain no symbols referenced by the binary.<br><br>This attribute is used by the C++ Starlark API when passing CcInfo providers.   | Boolean | optional |  `False`  |
| <a id="uniffi_library-compile_data"></a>compile_data |  List of files used by this rule at compile time.<br><br>This attribute can be used to specify any data files that are embedded into the library, such as via the [`include_str!`](https://doc.rust-lang.org/std/macro.include_str!.html) macro.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="uniffi_library-crate_features"></a>crate_features |  List of features to enable for this crate.<br><br>Features are defined in the code using the `#[cfg(feature = "foo")]` configuration option. The features listed here will be passed to `rustc` with `--cfg feature="${feature_name}"` flags.   | List of strings | optional |  `[]`  |
| <a id="uniffi_library-crate_name"></a>crate_name |  Crate name to use for this target.<br><br>This must be a valid Rust identifier, i.e. it may contain only alphanumeric characters and underscores. Defaults to the target name, with any hyphens replaced by underscores.   | String | optional |  `""`  |
| <a id="uniffi_library-crate_root"></a>crate_root |  The file that will be passed to `rustc` to be used for building this crate.<br><br>If `crate_root` is not set, then this rule will look for a `lib.rs` file (or `main.rs` for rust_binary) or the single file in `srcs` if `srcs` contains only one file.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="uniffi_library-edition"></a>edition |  The rust edition to use for this crate. Defaults to the edition specified in the rust_toolchain.   | String | optional |  `""`  |
| <a id="uniffi_library-package_name"></a>package_name |  Package name applied for kotlin bindings   | String | optional |  `"uniffi"`  |
| <a id="uniffi_library-proc_macro_deps"></a>proc_macro_deps |  List of `rust_proc_macro` targets used to help build this library target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="uniffi_library-rustc_env"></a>rustc_env |  Dictionary of additional `"key": "value"` environment variables to set for rustc.<br><br>rust_test()/rust_binary() rules can use $(rootpath //package:target) to pass in the location of a generated file or external tool. Cargo build scripts that wish to expand locations should use cargo_build_script()'s build_script_env argument instead, as build scripts are run in a different environment - see cargo_build_script()'s documentation for more.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="uniffi_library-rustc_env_files"></a>rustc_env_files |  Files containing additional environment variables to set for rustc.<br><br>These files should  contain a single variable per line, of format `NAME=value`, and newlines may be included in a value by ending a line with a trailing back-slash (`\\`).<br><br>The order that these files will be processed is unspecified, so multiple definitions of a particular variable are discouraged.<br><br>Note that the variables here are subject to [workspace status](https://docs.bazel.build/versions/main/user-manual.html#workspace_status) stamping should the `stamp` attribute be enabled. Stamp variables should be wrapped in brackets in order to be resolved. E.g. `NAME={WORKSPACE_STATUS_VARIABLE}`.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="uniffi_library-rustc_flags"></a>rustc_flags |  List of compiler flags passed to `rustc`.<br><br>These strings are subject to Make variable expansion for predefined source/output path variables like `$location`, `$execpath`, and `$rootpath`. This expansion is useful if you wish to pass a generated file of arguments to rustc: `@$(location //package:target)`.   | List of strings | optional |  `[]`  |
| <a id="uniffi_library-version"></a>version |  A version to inject in the cargo environment variable.   | String | optional |  `"0.0.0"`  |


<a id="uniffi_android_library"></a>

## uniffi_android_library

<pre>
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_android_library")

uniffi_android_library(<a href="#uniffi_android_library-name">name</a>, <a href="#uniffi_android_library-library">library</a>)
</pre>

Creates an android kotlin library from a uniffi library

Extract a kt_android_library from a uniffi_library definition


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="uniffi_android_library-name"></a>name |  Unique name for the generated kt_android_library   |  none |
| <a id="uniffi_android_library-library"></a>library |  Uniffi library generated from uniffi_library   |  none |


<a id="uniffi_kotlin_library"></a>

## uniffi_kotlin_library

<pre>
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_kotlin_library")

uniffi_kotlin_library(<a href="#uniffi_kotlin_library-name">name</a>, <a href="#uniffi_kotlin_library-library">library</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="uniffi_kotlin_library-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="uniffi_kotlin_library-library"></a>library |  <p align="center"> - </p>   |  none |


<a id="uniffi_swift_library"></a>

## uniffi_swift_library

<pre>
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_swift_library")

uniffi_swift_library(<a href="#uniffi_swift_library-name">name</a>, <a href="#uniffi_swift_library-library">library</a>, <a href="#uniffi_swift_library-module_name">module_name</a>)
</pre>

Creates a swift library from a uniffi library

Extract a swift_library from a uniffi_library definition


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="uniffi_swift_library-name"></a>name |  Unique name for the generated swift_library   |  none |
| <a id="uniffi_swift_library-library"></a>library |  Uniffi library generated from uniffi_library   |  none |
| <a id="uniffi_swift_library-module_name"></a>module_name |  Generated swift module name, (defaults to name)   |  `None` |



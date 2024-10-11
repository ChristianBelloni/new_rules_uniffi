# rules_uniffi

Starlark implementation for Mozilla's [uniffi]("https://github.com/mozilla/uniffi-rs") project

# Warning
This repo is in early stages of development and breaking changes will be frequent and without warning. DO NOT USE in production

## Overview

rules_uniffi enables you to write a single rust library and export ready-to-use bindings in kotlin and swift.

```uniffi_library``` is the entry point for all the rules exported by this module,<br>
it's identical to the [rules_rust](https://github.com/bazelbuild/rules_rust) implementation of [rust_library](https://bazelbuild.github.io/rules_rust/rust.html#rust_library).

### Currently supported languages and platforms:
 - android (rules_android v0.1.1)
 - kotlin
 - swift

## Getting started (TODO!)

## Using Bzlmod with Bazel 6

1. Enable with `common --enable_bzlmod` in `.bazelrc`.
2. Add to your `MODULE.bazel` file:

```starlark
bazel_dep(name = "rules_uniffi", version = "0.0.2")
```

## Using WORKSPACE

Paste this snippet into your  file:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_uniffi",
    sha256 = "4a06ab06fb802d0efaef4f43809bc1f7e878f5a715bc8349ee911ddc35b6372c",
    strip_prefix = "rules_uniffi-0.0.2",
    url = "https://github.com/ChristianBelloni/new_rules_uniffi/releases/download/0.0.2/rules_uniffi-0.0.2.tar.gz",
)

load("@rules_uniffi//uniffi:repositories.bzl", "rules_uniffi_dependencies")

rules_uniffi_dependencies()

load("@rules_uniffi//uniffi:setup.bzl", "rules_uniffi_setup")

rules_uniffi_setup()
```

For more in depth details see the [docs](docs/rules_uniffi.md) and the [examples](examples/)

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

### MODULE.bazel
```
bazel_dep(name = "rules_uniffi")

git_override(
    name = "rules_uniffi", 
    remote = "TODO", 
    commit = <commit hash>
)
```

For more in depth details see the [docs](docs/rules_uniffi.md) and the [examples](examples/)

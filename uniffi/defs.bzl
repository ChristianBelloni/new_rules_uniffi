"""
Rules to define a uniffi library
"""

load(
    "//uniffi/private:defs.bzl",
    _uniffi_android_library = "uniffi_android_library",
    _uniffi_kotlin_library = "uniffi_kotlin_library",
    _uniffi_library = "uniffi_library",
    _uniffi_swift_library = "uniffi_swift_library",
)

uniffi_library = _uniffi_library

uniffi_kotlin_library = _uniffi_kotlin_library

uniffi_android_library = _uniffi_android_library

uniffi_swift_library = _uniffi_swift_library

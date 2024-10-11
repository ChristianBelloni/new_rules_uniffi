load(
    "//uniffi/private:defs.bzl",
    _uniffi_android_library = "uniffi_android_library",
    _uniffi_kotlin_library = "uniffi_kotlin_library",
    _uniffi_library = "uniffi_library",
    _uniffi_swift_library = "uniffi_swift_library",
)


load("//uniffi/private:kotlin.bzl", _kt_android_library = "kt_android_library", _kt_android_local_test = "kt_android_local_test")

uniffi_library = _uniffi_library

uniffi_kotlin_library = _uniffi_kotlin_library

uniffi_android_library = _uniffi_android_library

uniffi_swift_library = _uniffi_swift_library


kt_android_library = _kt_android_library
kt_android_local_test = _kt_android_local_test

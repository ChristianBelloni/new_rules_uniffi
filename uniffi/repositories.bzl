load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
    "http_file",
    "http_jar",
)
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def rules_uniffi_dependencies():
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
    )
    maybe(
        http_file,
        name = "net_java_dev_jna_jna_aar",
        downloaded_file_path = "jna-5.14.0.aar",
        integrity = "sha256-gai5r8ZfnWsgUzjCWQivjeD/hBGgCYUQTJ2D//36s4A=",
        urls = ["https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.14.0/jna-5.14.0.aar"],
    )
    maybe(
        http_file,
        name = "net_java_dev_jna_jna_jar",
        downloaded_file_path = "jna-5.14.0.jar",
        integrity = "",
        urls = ["https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.14.0/jna-5.14.0.jar"],
    )

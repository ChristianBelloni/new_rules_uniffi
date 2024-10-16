#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
# The prefix is chosen to match what GitHub generates for source archives
PREFIX="rules_uniffi-${TAG}"
ARCHIVE="rules_uniffi-$TAG.tar.gz"
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat << EOF
## Using Bzlmod with Bazel 6

1. Enable with \`common --enable_bzlmod\` in \`.bazelrc\`.
2. Add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_uniffi", version = "${TAG}")
\`\`\`

## Using WORKSPACE

Paste this snippet into your `WORKSPACE.bazel` file:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_uniffi",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/ChristianBelloni/new_rules_uniffi/releases/download/${TAG}/${ARCHIVE}",
)

load("@rules_uniffi//uniffi:repositories.bzl", "rules_uniffi_dependencies")

rules_uniffi_dependencies()

load("@rules_uniffi//uniffi:setup.bzl", "rules_uniffi_setup")

rules_uniffi_setup()
EOF

echo "\`\`\`" 

#!/usr/bin/env bash
# Check that every package in uv.lock has a prebuilt wheel for the computers we
# run on, including older OS versions (which uv lock does not check). Run after
# changing uv.lock. esprima has only a source release; it is plain Python and
# builds anywhere.
# Usage (from the repo root): tools/check_wheels.sh
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
locked="$(mktemp)"
trap 'rm -f "$locked"' EXIT
uv export --locked --no-hashes --no-header --no-annotate -q >"$locked" || exit 1

status=0
# name, uv platform, macOS version (macOS only)
while read -r name platform macos; do
    out="$(MACOSX_DEPLOYMENT_TARGET="${macos/#-/}" uv pip compile "$locked" --python-version 3.10 \
        --python-platform "$platform" --only-binary :all: --no-binary esprima \
        --no-deps --no-header -q 2>&1)"
    if grep -q '^error' <<<"$out"; then
        echo "FAIL  $name: $(grep -m1 'cause' <<<"$out" | sed 's/.*Because //; s/ and you.*//')"
        status=1
    else
        echo "ok    $name"
    fi
done <<'LIST'
Ubuntu-22.04(glibc-2.35) x86_64-manylinux_2_35 -
macOS-14-Apple-Silicon aarch64-apple-darwin 14.0
Windows-x64 x86_64-pc-windows-msvc -
LIST
exit $status

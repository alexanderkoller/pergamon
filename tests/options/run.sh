#!/usr/bin/env bash
#
# This script test whether the tests in **/fail.typ panic.
# These are tests that are _supposed_ to panic, which is why we can't
# run them with `tt run`. Use this script instead.
#

set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
OUT=${TMPDIR:-/tmp}/pergamon-option-tests
mkdir -p "$OUT"

compile_ok() {
  local file=$1
  typst compile --root "$ROOT" "$ROOT/$file" "$OUT/$(echo "$file" | tr / _).pdf"
}

compile_fails() {
  local file=$1
  if typst compile --root "$ROOT" "$ROOT/$file" "$OUT/$(echo "$file" | tr / _).pdf" >/tmp/pergamon-option-test.log 2>&1; then
    echo "Expected compile failure, but succeeded: $file" >&2
    exit 1
  fi
}

compile_ok tests/options/on-duplicate/success/test.typ
compile_fails tests/options/on-duplicate/error-cross-source/fail.typ

compile_ok tests/options/missing-citation/placeholder/test.typ
compile_fails tests/options/missing-citation/error-numeric/fail.typ
compile_fails tests/options/missing-citation/error-alphabetic/fail.typ
compile_fails tests/options/missing-citation/error-authoryear/fail.typ

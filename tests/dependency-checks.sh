#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BINARY="$ROOT_DIR/pdfsandwich"

if [[ ! -x "$BINARY" ]]; then
  echo "Build pdfsandwich before running this test." >&2
  exit 2
fi

TRUE_BIN="$(command -v true)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
BIN_DIR="$WORK_DIR/bin"
mkdir -p "$BIN_DIR"

commands=(convert identify tesseract pdfinfo pdfunite unpaper gs hocr2pdf)
reset_commands() {
  rm -f "$BIN_DIR"/*
  for command_name in "${commands[@]}"; do
    ln -s "$TRUE_BIN" "$BIN_DIR/$command_name"
  done
}

run_expect_failure() {
  local omitted="$1"
  local expected="$2"
  shift 2
  reset_commands
  rm -f "$BIN_DIR/$omitted"

  set +e
  output="$(PATH="$BIN_DIR" "$BINARY" "$@" "$WORK_DIR/missing.pdf" 2>&1)"
  status=$?
  set -e

  if [[ $status -eq 0 ]]; then
    echo "Expected failure when $omitted is missing" >&2
    exit 1
  fi
  if ! grep -Fq "$expected" <<<"$output"; then
    echo "Expected message not found for $omitted: $expected" >&2
    echo "$output" >&2
    exit 1
  fi
}

run_expect_failure tesseract "Debian/Ubuntu: sudo apt-get install tesseract-ocr" -nopreproc
run_expect_failure pdfinfo "Debian/Ubuntu: sudo apt-get install poppler-utils" -nopreproc
run_expect_failure unpaper "Fedora/RHEL-like: sudo dnf install unpaper"
run_expect_failure gs "Could not find required program 'gs'" -nopreproc -pagesize 595x842

# Ghostscript is optional with the default page size. The program should warn
# about it and continue until it notices the deliberately missing input file.
reset_commands
rm -f "$BIN_DIR/gs"
set +e
output="$(PATH="$BIN_DIR" "$BINARY" -nopreproc "$WORK_DIR/missing.pdf" 2>&1)"
status=$?
set -e
[[ $status -ne 0 ]]
grep -Fq "Could not find optional program 'gs'" <<<"$output"
grep -Fq "Could not open file" <<<"$output"

echo "Dependency diagnostics passed."

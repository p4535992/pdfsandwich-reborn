#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT_DIR/pdfsandwich_version")"
OUTPUT_DIR="${1:-$ROOT_DIR/artifacts}"
PACKAGE_DIR="pdfsandwich-$VERSION"
SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-1533933677}"

mkdir -p "$OUTPUT_DIR"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$WORK_DIR/$PACKAGE_DIR"

(
  cd "$ROOT_DIR"
  tar \
    --exclude-vcs \
    --exclude='./artifacts' \
    --exclude='./rpmbuild' \
    --exclude='./debian/.debhelper' \
    --exclude='./debian/pdfsandwich' \
    --exclude='./obj-*' \
    --exclude='*.deb' \
    --exclude='*.rpm' \
    --exclude='*.src.rpm' \
    --exclude='*.tar.gz' \
    --exclude='*.tar.bz2' \
    --exclude='*.build' \
    --exclude='*.buildinfo' \
    --exclude='*.changes' \
    --exclude='pdfsandwich' \
    --exclude='pdfsandwich.1.gz' \
    --exclude='pdfsandwich_version.ml' \
    --exclude='makefile.installprefix' \
    -cf - .
) | tar -xf - -C "$WORK_DIR/$PACKAGE_DIR"

tar \
  --sort=name \
  --mtime="@$SOURCE_DATE_EPOCH" \
  --owner=0 --group=0 --numeric-owner \
  -czf "$OUTPUT_DIR/$PACKAGE_DIR.tar.gz" \
  -C "$WORK_DIR" "$PACKAGE_DIR"

(
  cd "$OUTPUT_DIR"
  sha256sum "$PACKAGE_DIR.tar.gz" > "$PACKAGE_DIR.tar.gz.sha256"
)

echo "$OUTPUT_DIR/$PACKAGE_DIR.tar.gz"

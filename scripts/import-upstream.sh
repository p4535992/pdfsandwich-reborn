#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_VERSION="0.1.7"
ARCHIVE="pdfsandwich-${UPSTREAM_VERSION}.tar.bz2"
EXPECTED_MD5="60e617cc398251cec5f42b870b1fccb4"
PRIMARY_URL="https://downloads.sourceforge.net/project/pdfsandwich/pdfsandwich%20${UPSTREAM_VERSION}/${ARCHIVE}"
FALLBACK_URL="https://sourceforge.net/projects/pdfsandwich/files/pdfsandwich%20${UPSTREAM_VERSION}/${ARCHIVE}/download"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

fetch_archive() {
  local url="$1"
  echo "Downloading upstream source from: $url"
  curl --fail --location --retry 3 --retry-delay 2 \
    --user-agent "pdfsandwich-maintenance-import/1" \
    --output "$WORK_DIR/$ARCHIVE" "$url"
}

if ! fetch_archive "$PRIMARY_URL"; then
  fetch_archive "$FALLBACK_URL"
fi

echo "$EXPECTED_MD5  $WORK_DIR/$ARCHIVE" | md5sum --check --status || {
  echo "ERROR: upstream archive checksum mismatch" >&2
  echo "Expected MD5: $EXPECTED_MD5" >&2
  md5sum "$WORK_DIR/$ARCHIVE" >&2 || true
  exit 1
}

tar -xjf "$WORK_DIR/$ARCHIVE" -C "$WORK_DIR"
SOURCE_DIR="$WORK_DIR/pdfsandwich-${UPSTREAM_VERSION}"

required_files=(
  Makefile
  README.md
  changelog
  changelog2deb.pl
  configure
  copyright
  ebuild-stub
  make_control.pl
  make_portfile.pl
  manual.txt
  pdfsandwich.ml
  pdfsandwich_version
  txt2man
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$SOURCE_DIR/$file" ]]; then
    echo "ERROR: expected upstream file is missing: $file" >&2
    exit 1
  fi
done

for file in "${required_files[@]}"; do
  case "$file" in
    README.md)
      install -m 0644 "$SOURCE_DIR/$file" "$ROOT_DIR/UPSTREAM_README.md"
      ;;
    changelog2deb.pl|configure|make_control.pl|make_portfile.pl|txt2man)
      install -m 0755 "$SOURCE_DIR/$file" "$ROOT_DIR/$file"
      ;;
    *)
      install -m 0644 "$SOURCE_DIR/$file" "$ROOT_DIR/$file"
      ;;
  esac
done

for patch_file in "$ROOT_DIR"/patches/*.patch; do
  [[ -e "$patch_file" ]] || continue
  echo "Applying $(basename "$patch_file")"
  patch --directory "$ROOT_DIR" --strip=1 --forward < "$patch_file"
done

cat > "$ROOT_DIR/UPSTREAM_SOURCE" <<EOF
Project: pdfsandwich
Original author: Tobias Elze
Version: ${UPSTREAM_VERSION}
Archive: ${ARCHIVE}
SourceForge URL: ${PRIMARY_URL}
Verified MD5: ${EXPECTED_MD5}
Imported by: scripts/import-upstream.sh
EOF

echo "Imported and patched pdfsandwich ${UPSTREAM_VERSION} successfully."

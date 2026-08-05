#!/usr/bin/env bash
set -euo pipefail

PDFSANDWICH_VERSION="${PDFSANDWICH_VERSION:-0.1.7.1}"
PDFSANDWICH_RELEASE_TAG="${PDFSANDWICH_RELEASE_TAG:-v${PDFSANDWICH_VERSION}}"
PDFSANDWICH_REPOSITORY="${PDFSANDWICH_REPOSITORY:-p4535992/pdfsandwich-reborn}"
TESSERACT_LANGUAGES="${TESSERACT_LANGUAGES:-all}"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates curl exactimage ghostscript imagemagick \
  poppler-utils tesseract-ocr unpaper

if [[ "$TESSERACT_LANGUAGES" == "all" ]]; then
  apt-get install -y --no-install-recommends tesseract-ocr-all
else
  IFS=',' read -r -a languages <<<"$TESSERACT_LANGUAGES"
  for lang in "${languages[@]}"; do
    apt-get install -y --no-install-recommends "tesseract-ocr-${lang}"
  done
fi

curl -fsSL -o /tmp/pdfsandwich.deb \
  "https://github.com/${PDFSANDWICH_REPOSITORY}/releases/download/${PDFSANDWICH_RELEASE_TAG}/pdfsandwich_${PDFSANDWICH_VERSION}-1_amd64.deb"
apt-get install -y --no-install-recommends /tmp/pdfsandwich.deb
rm -f /tmp/pdfsandwich.deb
rm -rf /var/lib/apt/lists/*

#!/usr/bin/env bash
set -euo pipefail

PDFSANDWICH_VERSION="${PDFSANDWICH_VERSION:-0.1.8}"
PDFSANDWICH_RELEASE_TAG="${PDFSANDWICH_RELEASE_TAG:-v${PDFSANDWICH_VERSION}}"
PDFSANDWICH_REPOSITORY="${PDFSANDWICH_REPOSITORY:-p4535992/pdfsandwich-reborn}"

# ImageMagick and unpaper are supplied through EPEL 9. Tesseract is deliberately
# built in Dockerfile.rocky because this project does not rely on an EL9 package.
dnf install -y dnf-plugins-core ca-certificates curl-minimal
dnf config-manager --set-enabled crb
dnf install -y \
  https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf install -y \
  ImageMagick ghostscript poppler-utils unpaper \
  libarchive libgomp libjpeg-turbo libstdc++ libpng libtiff libwebp zlib

curl -fsSL -o /tmp/pdfsandwich.rpm \
  "https://github.com/${PDFSANDWICH_REPOSITORY}/releases/download/${PDFSANDWICH_RELEASE_TAG}/pdfsandwich-${PDFSANDWICH_VERSION}-1.el9.x86_64.rpm"
dnf install -y --setopt=install_weak_deps=False /tmp/pdfsandwich.rpm
rm -f /tmp/pdfsandwich.rpm
dnf clean all
rm -rf /var/cache/dnf

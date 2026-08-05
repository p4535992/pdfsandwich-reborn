#!/usr/bin/env bash
set -euo pipefail

# Route PDF rasterization through Poppler to avoid common ImageMagick PDF
# security-policy restrictions. Non-PDF conversions are still delegated to
# ImageMagick by the wrapper.
exec /usr/bin/pdfsandwich \
  -convert /usr/local/libexec/pdfsandwich/convert-pdftoppm.sh \
  "$@"

#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Optional ImageMagick-compatible conversion wrapper for pdfsandwich.
# It sends PDF page rasterization to Poppler's pdftoppm, avoiding common
# ImageMagick security-policy restrictions on reading PDF files. Non-PDF
# conversion calls are delegated to ImageMagick.
#
# Inspired by the approach documented by Olivier Berger:
# https://gist.github.com/olberger/a88e3e2d4c684fdf94bbe5bc69ab9fe2

set -euo pipefail

if (($# < 2)); then
  echo "Usage: convert-pdftoppm.sh [ImageMagick options] INPUT OUTPUT" >&2
  exit 2
fi

args=("$@")
input="${args[$#-2]}"
output="${args[$#-1]}"

# pdfsandwich supplies ImageMagick page selectors as file.pdf[zero-based-page].
if [[ "$input" =~ ^(.*\.pdf)\[([0-9]+)\]$ ]]; then
  pdf_file="${BASH_REMATCH[1]}"
  page=$((BASH_REMATCH[2] + 1))
  dpi=300

  for ((i = 0; i < $#; i++)); do
    if [[ "${args[$i]}" == "-density" && $((i + 1)) -lt $# ]]; then
      dpi="${args[$((i + 1))]%%x*}"
      break
    fi
  done

  extension="${output##*.}"
  case "$extension" in
    pbm) format_option=(-mono); generated_extension="pbm" ;;
    pgm) format_option=(-gray); generated_extension="pgm" ;;
    ppm) format_option=(); generated_extension="ppm" ;;
    *)
      echo "Unsupported pdftoppm output extension: $extension" >&2
      exit 2
      ;;
  esac

  command -v pdftoppm >/dev/null 2>&1 || {
    echo "pdftoppm is required. Install poppler-utils." >&2
    exit 127
  }

  temporary_prefix="${output}.pdftoppm"
  rm -f "${temporary_prefix}.${generated_extension}"
  pdftoppm -singlefile -f "$page" -l "$page" -r "$dpi" \
    "${format_option[@]}" -- "$pdf_file" "$temporary_prefix"
  mv -- "${temporary_prefix}.${generated_extension}" "$output"
  exit 0
fi

if command -v magick >/dev/null 2>&1; then
  exec magick "$@"
elif command -v convert >/dev/null 2>&1; then
  exec convert "$@"
else
  echo "ImageMagick is required. Install imagemagick or ImageMagick." >&2
  exit 127
fi

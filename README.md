# pdfsandwich

A maintained continuation and packaging workspace for **pdfsandwich**, the command-line tool that adds an OCR text layer behind scanned PDF pages.

> This repository is not the original upstream project. The original author is Tobias Elze. Upstream history, copyright and GPL licensing are preserved.

## Upstream and provenance

- Original project page: https://www.tobias-elze.de/pdfsandwich/
- Original downloads and project archive: https://sourceforge.net/projects/pdfsandwich/
- Original source repository: https://sourceforge.net/p/pdfsandwich/code/HEAD/tree/trunk/src/
- Imported release: `pdfsandwich 0.1.7`, published on 2018-08-10
- Upstream archive: `pdfsandwich-0.1.7.tar.bz2`
- Verified upstream MD5: `60e617cc398251cec5f42b870b1fccb4`

The import script downloads the original SourceForge archive, verifies it against the checksum published by Debian/Ubuntu, extracts it, and applies the maintenance patches kept in `patches/`.

## License

The original source is licensed under the **GNU General Public License, version 2 or, at your option, any later version** (`GPL-2.0-or-later`). Original copyright notices are retained. See `LICENSE` and `copyright`.

## Runtime dependencies

pdfsandwich orchestrates external command-line tools. They are dependencies, not bundled source code.

| Purpose | Executables | Debian / Ubuntu package | Fedora / RHEL-like package |
|---|---|---|---|
| PDF image conversion and page inspection | `convert`, `identify`, or ImageMagick 7 `magick` | `imagemagick` | `ImageMagick` |
| OCR | `tesseract` | `tesseract-ocr` | `tesseract` |
| English OCR data | Tesseract `eng` language | `tesseract-ocr-eng` | `tesseract-langpack-eng` |
| PDF metadata and merging | `pdfinfo`, `pdfunite` | `poppler-utils` | `poppler-utils` |
| Scan cleanup | `unpaper` | `unpaper` | `unpaper` |
| PDF resizing / automatic downscaling | `gs` | `ghostscript` | `ghostscript` |
| Legacy Tesseract HOCR fallback | `hocr2pdf` | `exactimage` | `exact-image` when available |

Ghostscript is treated as conditional: it is required for explicit `-pagesize` changes and may be needed when `-maxpixels` causes automatic downscaling. `hocr2pdf` is only required with `-enforcehocr2pdf` or very old Tesseract versions.

LibreOffice, Pandoc and Docling are intentionally not part of this project or its build images.

### Debian / Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y \
  imagemagick ghostscript poppler-utils \
  tesseract-ocr tesseract-ocr-eng unpaper exactimage
```

Build dependencies:

```bash
sudo apt-get install -y make gawk ocaml-nox
```

### Fedora

```bash
sudo dnf install -y \
  ImageMagick ghostscript poppler-utils \
  tesseract tesseract-langpack-eng unpaper
```

Build dependencies:

```bash
sudo dnf install -y make gawk ocaml
```

### RHEL / Rocky / AlmaLinux

Some packages, notably ImageMagick and unpaper, may require EPEL and CRB/CodeReady Builder depending on the distribution release:

```bash
sudo dnf install -y dnf-plugins-core epel-release
sudo dnf config-manager --set-enabled crb || true
sudo dnf install -y \
  ImageMagick ghostscript poppler-utils \
  tesseract tesseract-langpack-eng unpaper \
  make gawk ocaml rpm-build
```

## Build from source

After the upstream source has been imported:

```bash
make
./pdfsandwich -version
sudo make PREFIX=/usr install
```

The maintained code checks dependencies before processing a document. Missing required programs produce an error with Debian/Ubuntu and Fedora/RHEL package hints. Optional components produce a warning. On ImageMagick 7 systems, pdfsandwich automatically falls back from the legacy `convert`/`identify` commands to `magick`/`magick identify` when appropriate.

## Packaging and GitHub Actions

The workflow in `.github/workflows/package.yml` builds and validates:

- a patched source archive: `pdfsandwich-<version>.tar.gz`
- a Debian/Ubuntu `.deb`
- a Red Hat-like `.rpm` and source RPM
- SHA-256 checksum files

Packaging is run for pull requests, pushes to `main`, version tags, and manual dispatches. Release publishing is intentionally separate from build validation.

The bootstrap workflow imports the pristine SourceForge archive only when the source is not already present. Subsequent development happens on the tracked source files, with the original import and maintenance patches documented.

## Related work reviewed

- Olivier Berger's `pdftoppm` conversion-wrapper idea: https://gist.github.com/olberger/a88e3e2d4c684fdf94bbe5bc69ab9fe2
- Carlos Ayam's Docker packaging experiment: https://github.com/carlosayam/pdfsandwich

A separately maintained `pdftoppm` wrapper is included under `contrib/` as an optional workaround for ImageMagick PDF security-policy restrictions. It is not enabled automatically.

## Project status

The first maintenance snapshot focuses on reproducible source import, preserved licensing, clearer dependency diagnostics, modern ImageMagick compatibility, and repeatable `.tar.gz`, `.deb`, and `.rpm` packaging. Functional changes beyond those compatibility and packaging fixes should be reviewed separately.

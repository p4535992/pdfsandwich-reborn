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

The import script downloads the original SourceForge archive, verifies its checksum, validates the expected file layout, extracts it, and applies the exact source transformations defined in `scripts/apply-maintenance.py`. The transformation script stops if the upstream code no longer matches the expected blocks, preventing a partial or misplaced update.

## Projects, executables and licenses

pdfsandwich invokes separate command-line programs. The normal `.deb` and `.rpm` packages depend on system packages; the optional **full runtime image** contains these tools together as an operating-system aggregate. Each component keeps its own license.

| Component | Executables / purpose | Official project or source | License summary |
|---|---|---|---|
| pdfsandwich | `pdfsandwich` OCR workflow | https://www.tobias-elze.de/pdfsandwich/ and https://sourceforge.net/projects/pdfsandwich/ | GPL-2.0-or-later |
| ImageMagick | `convert`, `identify`, `magick`; image conversion and inspection | https://github.com/ImageMagick/ImageMagick | ImageMagick License, Apache-2.0-style; attribution and license copy required |
| Tesseract OCR | `tesseract`; OCR engine | https://github.com/tesseract-ocr/tesseract | Apache-2.0 |
| Tesseract language data | OCR trained models | https://github.com/tesseract-ocr/tessdata | Apache-2.0 |
| Leptonica | Image-processing library used by Tesseract | https://github.com/DanBloomberg/leptonica | BSD-2-Clause-style license; consult the packaged notice |
| Ghostscript | `gs`; PDF resizing and rendering | https://github.com/ArtifexSoftware/ghostpdl and https://ghostscript.com/releases/ | AGPL-3.0-or-later for the open-source release, or a separate commercial license |
| Poppler | `pdfinfo`, `pdfunite`, `pdftoppm`; PDF inspection, merging and rasterization | https://poppler.freedesktop.org/ and https://gitlab.freedesktop.org/poppler/poppler | GPL family; the Xpdf-derived core is distributed under GPL-2.0 or GPL-3.0 and contributions include GPL-2.0-or-later notices |
| unpaper | `unpaper`; scan cleanup | https://github.com/unpaper/unpaper | Project GPL-2.0; some individual files use MIT or Apache-2.0 SPDX notices |
| ExactImage | `hocr2pdf`; legacy Tesseract fallback | https://exactcode.com/opensource/exactimage/ | GPL-2.0-only for the open-source release; commercial licensing is also offered |

The complete runtime image also contains Ubuntu and transitive library packages. Their exact versions and Debian copyright notices are copied into `/opt/pdfsandwich/licenses` inside the image and exported beside the release archive.

### License and redistribution notes

The pdfsandwich source remains **GPL-2.0-or-later**. The full runtime image is an aggregate of separate executables and libraries; it does not relicense those components under one common license. In particular, Ghostscript is distributed by Artifex under the **GNU Affero General Public License** or a commercial agreement. Anyone redistributing or offering the full image as a network service must review and satisfy the applicable AGPL obligations. ImageMagick requires its license and attribution to accompany redistribution. Poppler, unpaper and ExactImage carry GPL-family obligations. The image therefore includes package manifests, copyright notices and common license texts; this documentation is not a substitute for legal advice.

## Runtime dependencies

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
sudo apt-get install -y make gawk ocaml-nox perl
```

### Fedora

```bash
sudo dnf install -y \
  ImageMagick ghostscript poppler-utils \
  tesseract tesseract-langpack-eng unpaper
```

Build dependencies:

```bash
sudo dnf install -y make gawk ocaml perl-interpreter rpm-build
```

### RHEL / Rocky / AlmaLinux

Some packages, notably ImageMagick and unpaper, may require EPEL and CRB/CodeReady Builder depending on the distribution release:

```bash
sudo dnf install -y dnf-plugins-core epel-release
sudo dnf config-manager --set-enabled crb || true
sudo dnf install -y \
  ImageMagick ghostscript poppler-utils \
  tesseract tesseract-langpack-eng unpaper \
  make gawk ocaml perl-interpreter rpm-build
```

## Build from source

```bash
make
./pdfsandwich -version
sudo make PREFIX=/usr install
```

The maintained code checks dependencies before processing a document. Missing required programs produce an error with Debian/Ubuntu and Fedora/RHEL package hints. Optional components produce a warning. On ImageMagick 7 systems, pdfsandwich automatically falls back from the legacy `convert`/`identify` commands to `magick`/`magick identify` when appropriate.

## Full runtime image

The full image is based on Ubuntu 24.04 and includes:

- pdfsandwich;
- ImageMagick;
- Ghostscript;
- Poppler utilities;
- Tesseract OCR plus all Ubuntu Tesseract language packs;
- unpaper;
- ExactImage / `hocr2pdf`;
- component license notices and an installed-package manifest.

Build it locally:

```bash
docker build -f docker/full/Dockerfile -t pdfsandwich-full:local .
```

Run it against the current directory:

```bash
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$PWD:/work" -w /work \
  pdfsandwich-full:local \
  -lang ita+eng -o document_ocr.pdf document.pdf
```

The entrypoint automatically routes PDF page rasterization through Poppler's `pdftoppm`, avoiding common ImageMagick PDF security-policy restrictions. Normal ImageMagick conversions still use ImageMagick.

For every version tag, GitHub Actions adds a compressed Docker-compatible image archive named like `pdfsandwich-full-<version>-linux-amd64.docker.tar.gz`. Load it with:

```bash
gzip -dc pdfsandwich-full-<version>-linux-amd64.docker.tar.gz | docker load
```

## Packaging and GitHub Actions

The workflow in `.github/workflows/package.yml` builds and validates:

- a maintained source archive: `pdfsandwich-<version>.tar.gz`;
- a Debian/Ubuntu `.deb`;
- a Red Hat-like binary `.rpm` and source RPM;
- a full Linux amd64 runtime image archive with all OCR/PDF tools incorporated;
- license bundles, installed-package manifests and SHA-256 checksum files.

Packaging is run for pull requests, pushes to `main`, branches named `update/**`, version tags, and manual dispatches. A tag matching `v*` publishes all validated artifacts as a GitHub Release.

The bootstrap workflow imports the pristine SourceForge archive only when the tracked source is absent. Subsequent development happens on the imported source files, while `UPSTREAM_SOURCE` and the maintenance transformation record how the source was obtained and changed.

## Related work reviewed

- Olivier Berger's `pdftoppm` conversion-wrapper idea: https://gist.github.com/olberger/a88e3e2d4c684fdf94bbe5bc69ab9fe2
- Carlos Ayam's Docker packaging experiment: https://github.com/carlosayam/pdfsandwich

A separately maintained `pdftoppm` wrapper is included under `contrib/` and is enabled inside the full runtime image. It remains optional for native installations.

## Project status

The first maintenance snapshot focuses on reproducible source import, preserved licensing, clearer dependency diagnostics, modern ImageMagick compatibility, repeatable `.tar.gz`, `.deb`, `.rpm`, SRPM packaging, and a self-contained runtime image. Functional changes beyond those compatibility and packaging fixes should be reviewed separately.

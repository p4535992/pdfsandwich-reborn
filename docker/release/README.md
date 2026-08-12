# Release Dockerfiles

These files are attached directly to every tagged pdfsandwich GitHub Release.

The defaults in this directory track the current maintained release, **0.1.8**.
Override `PDFSANDWICH_VERSION` and `PDFSANDWICH_RELEASE_TAG` when testing a
specific release candidate or older release.

## Debian / Ubuntu family

`Dockerfile.debian` uses:

```dockerfile
FROM eclipse-temurin:21-jre AS runtime
```

It installs the complementary tools with `apt-get` and downloads the release
`.deb` asset:

```text
pdfsandwich_<version>-1_amd64.deb
```

Build:

```bash
docker build \
  -f Dockerfile.debian \
  --build-arg PDFSANDWICH_VERSION=0.1.8 \
  -t pdfsandwich-full-debian:0.1.8 .
```

Limit the Tesseract data instead of installing every available Ubuntu language:

```bash
docker build \
  -f Dockerfile.debian \
  --build-arg PDFSANDWICH_VERSION=0.1.8 \
  --build-arg TESSERACT_LANGUAGES=eng,ita \
  -t pdfsandwich-full-debian:0.1.8 .
```

## Red Hat / Rocky family

`Dockerfile.rocky` uses:

```dockerfile
FROM alfresco/alfresco-base-java:jre21-rockylinux9 AS runtime
```

It enables CRB and EPEL, installs ImageMagick, open-source Ghostscript, Poppler
and unpaper with `dnf`, builds Tesseract and Leptonica from pinned upstream
open-source release tags, and downloads the release EL9 RPM:

```text
pdfsandwich-<version>-1.el9.x86_64.rpm
```

Build:

```bash
docker build \
  -f Dockerfile.rocky \
  --build-arg PDFSANDWICH_VERSION=0.1.8 \
  -t pdfsandwich-full-rocky9:0.1.8 .
```

## Running either image

```bash
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$PWD:/work" -w /work \
  IMAGE_NAME \
  -lang ita+eng -o document_ocr.pdf document.pdf
```

Both variants route PDF rasterization through Poppler's `pdftoppm` wrapper.
Ghostscript is installed only from the open-source distribution repositories.
The Debian image also includes ExactImage / `hocr2pdf`; the Rocky image uses
modern Tesseract's native PDF renderer and does not add the unmaintained
ExactImage toolkit.

The full source-checkout Dockerfiles live under `docker/full/`. The release
Dockerfiles in this directory are self-contained and download the matching
release package, so a source checkout is not required.

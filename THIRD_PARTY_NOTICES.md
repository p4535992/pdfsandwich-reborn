# Third-party notices for the pdfsandwich full runtime image

The full runtime image is an aggregate of separate programs and libraries. Each component remains under its own license. This file summarizes the direct OCR/PDF components; `/opt/pdfsandwich/licenses/packages` inside the image contains Debian copyright notices for all installed packages, `/opt/pdfsandwich/licenses/common` contains common license texts, and `installed-packages.tsv` records the exact package versions.

| Component | Upstream | License / important condition |
|---|---|---|
| pdfsandwich | https://www.tobias-elze.de/pdfsandwich/ and https://sourceforge.net/projects/pdfsandwich/ | GNU GPL version 2 or, at your option, any later version. The complete GPLv2 text is in `LICENSE`; original attribution is in `copyright`. |
| ImageMagick | https://github.com/ImageMagick/ImageMagick and https://imagemagick.org/license/ | ImageMagick License. Redistribution requires the license and clear attribution to ImageMagick Studio LLC. |
| Tesseract OCR | https://github.com/tesseract-ocr/tesseract | Apache License 2.0. |
| Tesseract language data | https://github.com/tesseract-ocr/tessdata | Apache License 2.0. |
| Leptonica | https://github.com/DanBloomberg/leptonica | Permissive two-clause BSD-style license requiring preservation of copyright, conditions and disclaimer. |
| Ghostscript | https://github.com/ArtifexSoftware/ghostpdl and https://ghostscript.com/releases/ | Open-source releases are under GNU AGPL version 3 or later; Artifex also offers commercial licensing. Review AGPL source and network-use obligations before redistribution or hosted use. |
| Poppler | https://poppler.freedesktop.org/ and https://gitlab.freedesktop.org/poppler/poppler | GPL-family licensing. The Xpdf-derived core is distributed under GPLv2 or GPLv3; newer contributions include GPLv2-or-later notices. Consult the packaged Debian copyright file and upstream `COPYING` / `COPYING3`. |
| unpaper | https://github.com/unpaper/unpaper | The project is GPLv2; individual files may carry MIT or Apache-2.0 SPDX identifiers. |
| ExactImage / hocr2pdf | https://exactcode.com/opensource/exactimage/ | Open-source release GPLv2-only; commercial licensing is also available from ExactCODE. |
| Ubuntu base and transitive packages | https://packages.ubuntu.com/ | Mixed free-software licenses. Exact package versions and their Debian copyright notices are included in the image license directory. |

## Source availability and reproducibility

The image is built entirely from the repository source and Ubuntu archive packages. The installed package manifest records binary package names, versions and source-package names. Corresponding Ubuntu source packages can be retrieved with Ubuntu's standard source repositories and `apt-get source <source-package>=<version>` when that exact version remains available, or from Ubuntu's package archive/snapshot services.

The release also publishes:

- the maintained pdfsandwich source archive;
- `.deb`, binary RPM and source RPM packages;
- the compressed full-runtime image archive;
- the extracted image license directory and package manifest;
- SHA-256 checksums.

No component is relicensed by this aggregate. Users and redistributors remain responsible for complying with every applicable component license. This notice is informational and is not legal advice.

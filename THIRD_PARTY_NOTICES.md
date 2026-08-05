# Third-party notices for the pdfsandwich full runtime images

The full runtime images are operating-system aggregates of separate programs and libraries. Each component remains under its own license. No component is relicensed under the pdfsandwich license.

This project builds two variants:

- **Debian/Ubuntu:** `eclipse-temurin:21-jre`
- **Red Hat/Rocky:** `alfresco/alfresco-base-java:jre21-rockylinux9`

Both variants install **only the open-source Ghostscript package supplied by the selected Linux distribution repositories**. No Artifex commercial Ghostscript binary or commercial license is embedded.

| Component | Upstream | License / important condition |
|---|---|---|
| pdfsandwich | https://www.tobias-elze.de/pdfsandwich/ and https://sourceforge.net/projects/pdfsandwich/ | GNU GPL version 2 or, at your option, any later version. The complete GPLv2 text is in `LICENSE`; original attribution is in `copyright`. |
| ImageMagick | https://github.com/ImageMagick/ImageMagick and https://imagemagick.org/license/ | ImageMagick License. Redistribution requires preservation of the license and attribution notices. |
| Tesseract OCR | https://github.com/tesseract-ocr/tesseract | Apache License 2.0. The Rocky image builds the pinned upstream tag from source. |
| Tesseract language data | https://github.com/tesseract-ocr/tessdata and https://github.com/tesseract-ocr/tessdata_fast | Apache License 2.0. Debian can install all packaged languages; Rocky includes the pinned `tessdata_fast` release. |
| Leptonica | https://github.com/DanBloomberg/leptonica | Permissive two-clause BSD-style license requiring preservation of copyright, conditions and disclaimer. The Rocky image builds the pinned upstream tag from source. |
| Ghostscript | https://github.com/ArtifexSoftware/ghostpdl and https://ghostscript.com/releases/ | The open-source release is GNU AGPL version 3 or later. These images install the distribution's open-source package only. Review AGPL source and network-use obligations before redistribution or hosted use. |
| Poppler | https://poppler.freedesktop.org/ and https://gitlab.freedesktop.org/poppler/poppler | GPL-family licensing. Consult the package notices and upstream copying files. |
| unpaper | https://github.com/unpaper/unpaper | Project GPL-2.0; some individual files carry MIT or Apache-2.0 SPDX identifiers. |
| ExactImage / hocr2pdf | https://exactcode.com/opensource/exactimage/ | Open-source release GPL-2.0-only. Included in the Debian image as the legacy HOCR fallback; not included in the Rocky image. |
| Eclipse Temurin JRE | https://github.com/adoptium/temurin-build | OpenJDK distribution under GPL-2.0-with-classpath-exception plus component-specific notices. Consult the base image notices. |
| Alfresco base Java image | https://hub.docker.com/r/alfresco/alfresco-base-java | Rocky Linux 9 / Java 21 base maintained by Alfresco. Its inherited packages and Java runtime retain their own licenses and notices. |
| Ubuntu, Rocky Linux, EPEL and transitive packages | Distribution package repositories | Mixed free-software licenses. Exact installed package versions and package license metadata are exported with each image. |

## Included license material

The Debian/Ubuntu image exports:

- `/opt/pdfsandwich/licenses/packages`: Debian package copyright notices;
- `/opt/pdfsandwich/licenses/common`: common Debian license texts;
- `/opt/pdfsandwich/licenses/installed-packages.tsv`: exact package and source-package versions.

The Rocky image exports:

- `/opt/pdfsandwich/licenses/rpm`: RPM package license directories when supplied by the packages;
- `/opt/pdfsandwich/licenses/source`: license files copied from the pinned Tesseract, Leptonica and tessdata source archives;
- `/opt/pdfsandwich/licenses/installed-packages.tsv`: RPM names, versions, architectures and declared license fields.

Each image also contains a `bundle-manifest.txt` identifying the runtime variant, base image, pdfsandwich version and the fact that Ghostscript came from the open-source distribution package.

## Source availability and release artifacts

Tagged releases publish:

- the maintained pdfsandwich source archive;
- Debian `.deb`, Fedora RPM/SRPM and EL9 RPM/SRPM packages;
- compressed Docker-compatible archives for both runtime variants;
- extracted license bundles and installed-package manifests;
- standalone Debian and Rocky Dockerfiles that download the matching release package;
- installation scripts showing every `apt` or `dnf` command;
- SHA-256 checksums.

The Rocky Dockerfiles also show the exact upstream tags and commands used to build Tesseract and Leptonica when an appropriate EL9 package is not used.

Users and redistributors remain responsible for complying with every applicable component license. This notice is informational and is not legal advice.

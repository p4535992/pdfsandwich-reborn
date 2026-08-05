# syntax=docker/dockerfile:1.7

# Tesseract is not supplied as a maintained EL9 package in the repositories
# used by this image, so it and Leptonica are built from open-source tags.
FROM rockylinux:9 AS tesseract-builder

ARG LEPTONICA_VERSION=1.87.0
ARG TESSERACT_VERSION=5.5.2
ARG TESSDATA_VERSION=4.1.0

RUN dnf install -y dnf-plugins-core ca-certificates curl \
    && dnf config-manager --set-enabled crb \
    && dnf install -y \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf install -y \
      cmake gcc gcc-c++ giflib-devel libjpeg-turbo-devel libpng-devel \
      libtiff-devel libwebp-devel make openjpeg2-devel pkgconf-pkg-config \
      tar zlib-devel \
    && dnf clean all

WORKDIR /build

RUN curl -fsSL -o leptonica.tar.gz \
      "https://github.com/DanBloomberg/leptonica/archive/refs/tags/${LEPTONICA_VERSION}.tar.gz" \
    && tar -xzf leptonica.tar.gz \
    && cmake -S "leptonica-${LEPTONICA_VERSION}" -B leptonica-build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/tesseract \
      -DBUILD_PROG=OFF \
    && cmake --build leptonica-build --parallel \
    && cmake --install leptonica-build

ENV CMAKE_PREFIX_PATH=/opt/tesseract \
    PKG_CONFIG_PATH=/opt/tesseract/lib64/pkgconfig:/opt/tesseract/lib/pkgconfig

RUN curl -fsSL -o tesseract.tar.gz \
      "https://github.com/tesseract-ocr/tesseract/archive/refs/tags/${TESSERACT_VERSION}.tar.gz" \
    && tar -xzf tesseract.tar.gz \
    && cmake -S "tesseract-${TESSERACT_VERSION}" -B tesseract-build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/tesseract \
      -DBUILD_TRAINING_TOOLS=OFF \
      -DDISABLE_ARCHIVE=ON \
      -DDISABLE_CURL=ON \
    && cmake --build tesseract-build --parallel \
    && cmake --install tesseract-build

RUN curl -fsSL -o tessdata.tar.gz \
      "https://github.com/tesseract-ocr/tessdata_fast/archive/refs/tags/${TESSDATA_VERSION}.tar.gz" \
    && tar -xzf tessdata.tar.gz \
    && mkdir -p /opt/tesseract/share/tessdata \
    && find "tessdata_fast-${TESSDATA_VERSION}" -maxdepth 1 -type f \
      \( -name '*.traineddata' -o -name 'pdf.ttf' \) \
      -exec cp {} /opt/tesseract/share/tessdata/ \; \
    && for directory in configs script tessconfigs; do \
         if [ -e "tessdata_fast-${TESSDATA_VERSION}/${directory}" ]; then \
           cp -a "tessdata_fast-${TESSDATA_VERSION}/${directory}" /opt/tesseract/share/tessdata/; \
         fi; \
       done \
    && mkdir -p /licenses/tesseract /licenses/leptonica /licenses/tessdata-fast \
    && cp "tesseract-${TESSERACT_VERSION}/LICENSE" /licenses/tesseract/ \
    && cp "leptonica-${LEPTONICA_VERSION}/leptonica-license.txt" /licenses/leptonica/ \
    && cp "tessdata_fast-${TESSDATA_VERSION}/LICENSE" /licenses/tessdata-fast/

FROM alfresco/alfresco-base-java:jre21-rockylinux9 AS runtime

USER root

ARG PDFSANDWICH_VERSION=0.1.7.1
ARG PDFSANDWICH_RELEASE_TAG=
ARG PDFSANDWICH_REPOSITORY=p4535992/pdfsandwich
ARG LEPTONICA_VERSION=1.87.0
ARG TESSERACT_VERSION=5.5.2
ARG TESSDATA_VERSION=4.1.0

LABEL org.opencontainers.image.title="pdfsandwich release runtime (Rocky Linux)" \
      org.opencontainers.image.description="Release-installable pdfsandwich runtime on Alfresco Java 21 Rocky Linux 9" \
      org.opencontainers.image.version="${PDFSANDWICH_VERSION}" \
      org.opencontainers.image.source="https://github.com/p4535992/pdfsandwich" \
      org.opencontainers.image.base.name="docker.io/alfresco/alfresco-base-java:jre21-rockylinux9" \
      org.opencontainers.image.licenses="LicenseRef-Aggregate-See-Third-Party-Notices"

RUN dnf install -y dnf-plugins-core ca-certificates curl findutils gzip tar \
    && dnf config-manager --set-enabled crb \
    && dnf install -y \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf install -y \
      ImageMagick ghostscript libarchive libgomp libjpeg-turbo libstdc++ \
      libpng libtiff libwebp poppler-utils unpaper zlib \
    && dnf clean all \
    && rm -rf /var/cache/dnf

COPY --from=tesseract-builder /opt/tesseract/ /opt/tesseract/
COPY --from=tesseract-builder /licenses/ /opt/pdfsandwich/licenses/source/

RUN tag="${PDFSANDWICH_RELEASE_TAG:-v${PDFSANDWICH_VERSION}}" \
    && curl -fsSL -o /tmp/pdfsandwich.rpm \
      "https://github.com/${PDFSANDWICH_REPOSITORY}/releases/download/${tag}/pdfsandwich-${PDFSANDWICH_VERSION}-1.el9.x86_64.rpm" \
    && dnf install -y --setopt=install_weak_deps=False /tmp/pdfsandwich.rpm \
    && rm -f /tmp/pdfsandwich.rpm \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN tag="${PDFSANDWICH_RELEASE_TAG:-v${PDFSANDWICH_VERSION}}" \
    && mkdir -p /usr/local/libexec/pdfsandwich /opt/pdfsandwich/project \
    && curl -fsSL -o /usr/local/libexec/pdfsandwich/convert-pdftoppm.sh \
      "https://raw.githubusercontent.com/${PDFSANDWICH_REPOSITORY}/${tag}/contrib/convert-pdftoppm.sh" \
    && curl -fsSL -o /opt/pdfsandwich/project/LICENSE \
      "https://raw.githubusercontent.com/${PDFSANDWICH_REPOSITORY}/${tag}/LICENSE" \
    && curl -fsSL -o /opt/pdfsandwich/THIRD_PARTY_NOTICES.md \
      "https://raw.githubusercontent.com/${PDFSANDWICH_REPOSITORY}/${tag}/THIRD_PARTY_NOTICES.md" \
    && cat > /usr/local/bin/pdfsandwich-full <<'ENTRYPOINT'
#!/usr/bin/env bash
set -euo pipefail
exec /usr/bin/pdfsandwich \
  -convert /usr/local/libexec/pdfsandwich/convert-pdftoppm.sh \
  "$@"
ENTRYPOINT
RUN chmod 0755 \
      /usr/local/bin/pdfsandwich-full \
      /usr/local/libexec/pdfsandwich/convert-pdftoppm.sh \
    && printf '%s\n' /opt/tesseract/lib64 /opt/tesseract/lib \
      > /etc/ld.so.conf.d/pdfsandwich-tesseract.conf \
    && ldconfig \
    && mkdir -p /opt/pdfsandwich/licenses/rpm \
    && if [ -d /usr/share/licenses ]; then \
         cp -a /usr/share/licenses/. /opt/pdfsandwich/licenses/rpm/; \
       fi \
    && rpm -qa --qf '%{NAME}\t%{VERSION}-%{RELEASE}\t%{ARCH}\t%{LICENSE}\n' \
      | LC_ALL=C sort \
      > /opt/pdfsandwich/licenses/installed-packages.tsv \
    && mkdir -p /work

ENV PATH=/opt/tesseract/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/tesseract/lib64:/opt/tesseract/lib \
    TESSDATA_PREFIX=/opt/tesseract/share/tessdata \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/pdfsandwich-full"]
CMD ["-help"]

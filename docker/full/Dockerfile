# syntax=docker/dockerfile:1

FROM ubuntu:24.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      gawk \
      make \
      ocaml-nox \
      perl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

RUN chmod +x \
      configure \
      changelog2deb.pl \
      make_control.pl \
      make_portfile.pl \
      txt2man \
      contrib/convert-pdftoppm.sh \
      docker/full/entrypoint.sh \
    && echo PREFIX=/usr > makefile.installprefix \
    && make clean \
    && make all \
    && make DESTDIR=/stage PREFIX=/usr INSTALL=install install

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG PDFSANDWICH_VERSION=0.1.7.1

LABEL org.opencontainers.image.title="pdfsandwich full runtime" \
      org.opencontainers.image.description="pdfsandwich with Tesseract, Ghostscript, Poppler, ImageMagick, unpaper and ExactImage" \
      org.opencontainers.image.version="${PDFSANDWICH_VERSION}" \
      org.opencontainers.image.source="https://github.com/p4535992/pdfsandwich" \
      org.opencontainers.image.licenses="LicenseRef-Aggregate-See-Third-Party-Notices"

# Ubuntu container images normally exclude most package documentation. Keep
# Debian copyright files so every incorporated binary and library retains its
# redistribution notice inside the image.
RUN printf '%s\n' \
      'path-include=/usr/share/doc/*/copyright' \
      'path-include=/usr/share/common-licenses/**' \
      > /etc/dpkg/dpkg.cfg.d/zz-pdfsandwich-license-files \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      exactimage \
      ghostscript \
      imagemagick \
      poppler-utils \
      tesseract-ocr \
      tesseract-ocr-all \
      unpaper \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /stage/usr/ /usr/
COPY contrib/convert-pdftoppm.sh /usr/local/libexec/pdfsandwich/convert-pdftoppm.sh
COPY docker/full/entrypoint.sh /usr/local/bin/pdfsandwich-full
COPY THIRD_PARTY_NOTICES.md /opt/pdfsandwich/THIRD_PARTY_NOTICES.md
COPY LICENSE copyright README.md UPSTREAM_SOURCE /opt/pdfsandwich/project/

RUN chmod 0755 \
      /usr/local/bin/pdfsandwich-full \
      /usr/local/libexec/pdfsandwich/convert-pdftoppm.sh \
    && mkdir -p \
      /opt/pdfsandwich/licenses/packages \
      /opt/pdfsandwich/licenses/common \
    && cp -a /usr/share/common-licenses/. /opt/pdfsandwich/licenses/common/ \
    && find /usr/share/doc -mindepth 2 -maxdepth 2 -type f -name copyright -print0 \
      | while IFS= read -r -d '' notice; do \
          package="$(basename "$(dirname "$notice")")"; \
          cp "$notice" "/opt/pdfsandwich/licenses/packages/${package}.copyright"; \
        done \
    && dpkg-query -W -f='${binary:Package}\t${Version}\t${source:Package}\n' \
      | LC_ALL=C sort \
      > /opt/pdfsandwich/licenses/installed-packages.tsv \
    && { \
      echo 'pdfsandwich full runtime'; \
      echo "version=${PDFSANDWICH_VERSION}"; \
      echo "ubuntu=$(awk -F= '/^VERSION_ID=/{gsub(/\"/, "", $2); print $2}' /etc/os-release)"; \
      echo "architecture=$(dpkg --print-architecture)"; \
      echo "built_at=${SOURCE_DATE_EPOCH:-not-recorded}"; \
    } > /opt/pdfsandwich/licenses/bundle-manifest.txt \
    && mkdir -p /work

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/pdfsandwich-full"]
CMD ["-help"]

# syntax=docker/dockerfile:1.7

FROM ubuntu:24.04 AS pdfsandwich-builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
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

FROM eclipse-temurin:21-jre AS runtime

USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG PDFSANDWICH_VERSION=0.1.8
ARG TESSERACT_LANGUAGES=all

LABEL org.opencontainers.image.title="pdfsandwich full runtime (Debian/Ubuntu)" \
      org.opencontainers.image.description="pdfsandwich with open-source Ghostscript, Tesseract, Poppler, ImageMagick, unpaper and ExactImage on Eclipse Temurin 21 JRE" \
      org.opencontainers.image.version="${PDFSANDWICH_VERSION}" \
      org.opencontainers.image.source="https://github.com/p4535992/pdfsandwich-reborn" \
      org.opencontainers.image.base.name="docker.io/library/eclipse-temurin:21-jre" \
      org.opencontainers.image.licenses="LicenseRef-Aggregate-See-Third-Party-Notices"

# Container base images commonly exclude package documentation. Keep copyright
# notices and common license texts for every installed Debian package.
RUN printf '%s\n' \
      'path-include=/usr/share/doc/*/copyright' \
      'path-include=/usr/share/common-licenses/**' \
      > /etc/dpkg/dpkg.cfg.d/zz-pdfsandwich-license-files \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      exactimage \
      ghostscript \
      imagemagick \
      poppler-utils \
      tesseract-ocr \
      unpaper \
    && if [ "${TESSERACT_LANGUAGES}" = "all" ]; then \
         apt-get install -y --no-install-recommends tesseract-ocr-all; \
       else \
         for lang in $(printf '%s' "${TESSERACT_LANGUAGES}" | tr ',' ' '); do \
           apt-get install -y --no-install-recommends "tesseract-ocr-${lang}"; \
         done; \
       fi \
    && rm -rf /var/lib/apt/lists/*

COPY --from=pdfsandwich-builder /stage/usr/ /usr/
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
    && find /usr/share/doc -mindepth 2 -maxdepth 2 -type f -name copyright \
      -exec sh -c 'for notice do package="$(basename "$(dirname "$notice")")"; cp "$notice" "/opt/pdfsandwich/licenses/packages/${package}.copyright"; done' sh {} + \
    && dpkg-query -W -f='${binary:Package}\t${Version}\t${source:Package}\n' \
      | LC_ALL=C sort \
      > /opt/pdfsandwich/licenses/installed-packages.tsv \
    && { \
      echo 'pdfsandwich full runtime'; \
      echo 'variant=debian-temurin21'; \
      echo "version=${PDFSANDWICH_VERSION}"; \
      echo "base_image=eclipse-temurin:21-jre"; \
      echo 'ghostscript_distribution=open-source-distro-package'; \
      echo "architecture=$(dpkg --print-architecture)"; \
    } > /opt/pdfsandwich/licenses/bundle-manifest.txt \
    && mkdir -p /work

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/pdfsandwich-full"]
CMD ["-help"]

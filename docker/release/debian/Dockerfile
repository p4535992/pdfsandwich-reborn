# syntax=docker/dockerfile:1.7

# Published as a release asset. No source checkout is required: this image
# downloads the .deb produced by the same GitHub Release.
FROM eclipse-temurin:21-jre AS runtime

USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG PDFSANDWICH_VERSION=0.1.8
ARG PDFSANDWICH_RELEASE_TAG=
ARG PDFSANDWICH_REPOSITORY=p4535992/pdfsandwich-reborn
ARG TESSERACT_LANGUAGES=all

LABEL org.opencontainers.image.title="pdfsandwich release runtime (Debian/Ubuntu)" \
      org.opencontainers.image.description="Release-installable pdfsandwich runtime on Eclipse Temurin 21 JRE" \
      org.opencontainers.image.version="${PDFSANDWICH_VERSION}" \
      org.opencontainers.image.source="https://github.com/p4535992/pdfsandwich-reborn" \
      org.opencontainers.image.base.name="docker.io/library/eclipse-temurin:21-jre" \
      org.opencontainers.image.licenses="LicenseRef-Aggregate-See-Third-Party-Notices"

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
    && tag="${PDFSANDWICH_RELEASE_TAG:-v${PDFSANDWICH_VERSION}}" \
    && curl -fsSL -o /tmp/pdfsandwich.deb \
      "https://github.com/${PDFSANDWICH_REPOSITORY}/releases/download/${tag}/pdfsandwich_${PDFSANDWICH_VERSION}-1_amd64.deb" \
    && apt-get install -y --no-install-recommends /tmp/pdfsandwich.deb \
    && rm -f /tmp/pdfsandwich.deb \
    && rm -rf /var/lib/apt/lists/*

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
    && mkdir -p \
      /opt/pdfsandwich/licenses/packages \
      /opt/pdfsandwich/licenses/common \
    && cp -a /usr/share/common-licenses/. /opt/pdfsandwich/licenses/common/ \
    && find /usr/share/doc -mindepth 2 -maxdepth 2 -type f -name copyright \
      -exec sh -c 'for notice do package="$(basename "$(dirname "$notice")")"; cp "$notice" "/opt/pdfsandwich/licenses/packages/${package}.copyright"; done' sh {} + \
    && dpkg-query -W -f='${binary:Package}\t${Version}\t${source:Package}\n' \
      | LC_ALL=C sort \
      > /opt/pdfsandwich/licenses/installed-packages.tsv \
    && mkdir -p /work

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/pdfsandwich-full"]
CMD ["-help"]

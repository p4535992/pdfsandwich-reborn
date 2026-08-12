# syntax=docker/dockerfile:1.7

FROM rockylinux:9 AS pdfsandwich-builder

RUN dnf install -y dnf-plugins-core ca-certificates curl-minimal \
    && dnf config-manager --set-enabled crb \
    && dnf install -y \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf install -y \
      gawk \
      make \
      ocaml \
      perl-interpreter \
    && dnf clean all

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

FROM rockylinux:9 AS tesseract-builder

ARG LEPTONICA_VERSION=1.87.0
ARG TESSERACT_VERSION=5.5.2
ARG TESSDATA_VERSION=4.1.0

RUN dnf install -y dnf-plugins-core ca-certificates curl-minimal \
    && dnf config-manager --set-enabled crb \
    && dnf install -y \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf install -y \
      cmake \
      gcc \
      gcc-c++ \
      giflib-devel \
      libjpeg-turbo-devel \
      libpng-devel \
      libtiff-devel \
      libwebp-devel \
      make \
      openjpeg2-devel \
      pkgconf-pkg-config \
      tar \
      zlib-devel \
    && dnf clean all

WORKDIR /build

RUN curl -fsSL -o leptonica.tar.gz \
      "https://github.com/DanBloomberg/leptonica/archive/refs/tags/${LEPTONICA_VERSION}.tar.gz" \
    && tar -xzf leptonica.tar.gz \
    && cmake \
      -S "leptonica-${LEPTONICA_VERSION}" \
      -B leptonica-build \
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
    && cmake \
      -S "tesseract-${TESSERACT_VERSION}" \
      -B tesseract-build \
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

ARG PDFSANDWICH_VERSION=0.1.8
ARG LEPTONICA_VERSION=1.87.0
ARG TESSERACT_VERSION=5.5.2
ARG TESSDATA_VERSION=4.1.0

LABEL org.opencontainers.image.title="pdfsandwich full runtime (Rocky Linux)" \
      org.opencontainers.image.description="pdfsandwich with open-source Ghostscript, source-built Tesseract, Poppler, ImageMagick and unpaper on Alfresco Java 21 Rocky Linux 9" \
      org.opencontainers.image.version="${PDFSANDWICH_VERSION}" \
      org.opencontainers.image.source="https://github.com/p4535992/pdfsandwich-reborn" \
      org.opencontainers.image.base.name="docker.io/alfresco/alfresco-base-java:jre21-rockylinux9" \
      org.opencontainers.image.licenses="LicenseRef-Aggregate-See-Third-Party-Notices"

RUN dnf install -y dnf-plugins-core ca-certificates curl-minimal findutils gzip tar \
    && dnf config-manager --set-enabled crb \
    && dnf install -y \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf install -y \
      ImageMagick \
      ghostscript \
      libarchive \
      libgomp \
      libjpeg-turbo \
      libstdc++ \
      libpng \
      libtiff \
      libwebp \
      poppler-utils \
      unpaper \
      zlib \
    && dnf clean all \
    && rm -rf /var/cache/dnf

COPY --from=pdfsandwich-builder /stage/usr/ /usr/
COPY --from=tesseract-builder /opt/tesseract/ /opt/tesseract/
COPY --from=tesseract-builder /licenses/ /opt/pdfsandwich/licenses/source/
COPY contrib/convert-pdftoppm.sh /usr/local/libexec/pdfsandwich/convert-pdftoppm.sh
COPY docker/full/entrypoint.sh /usr/local/bin/pdfsandwich-full
COPY THIRD_PARTY_NOTICES.md /opt/pdfsandwich/THIRD_PARTY_NOTICES.md
COPY LICENSE copyright README.md UPSTREAM_SOURCE /opt/pdfsandwich/project/

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
    && { \
      echo 'pdfsandwich full runtime'; \
      echo 'variant=rocky9-alfresco-jre21'; \
      echo "version=${PDFSANDWICH_VERSION}"; \
      echo 'base_image=alfresco/alfresco-base-java:jre21-rockylinux9'; \
      echo 'ghostscript_distribution=open-source-distro-package'; \
      echo "tesseract=${TESSERACT_VERSION}"; \
      echo "leptonica=${LEPTONICA_VERSION}"; \
      echo "tessdata_fast=${TESSDATA_VERSION}"; \
      echo "architecture=$(rpm --eval '%{_arch}')"; \
    } > /opt/pdfsandwich/licenses/bundle-manifest.txt \
    && mkdir -p /work

ENV PATH=/opt/tesseract/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/tesseract/lib64:/opt/tesseract/lib \
    TESSDATA_PREFIX=/opt/tesseract/share/tessdata \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/pdfsandwich-full"]
CMD ["-help"]

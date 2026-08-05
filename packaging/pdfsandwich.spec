Name:           pdfsandwich
Version:        0.1.7.1
Release:        1%{?dist}
Summary:        Generate searchable OCR sandwich PDF files

License:        GPL-2.0-or-later
URL:            https://www.tobias-elze.de/pdfsandwich/
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gawk
BuildRequires:  make
BuildRequires:  ocaml
BuildRequires:  perl-interpreter
Requires:       ImageMagick
Requires:       poppler-utils
Requires:       unpaper

# Fedora installs Tesseract as a normal runtime dependency. The EL9 full image
# deliberately builds Tesseract and Leptonica from pinned open-source tags, so
# the EL9 RPM keeps Tesseract as a weak dependency and is installed with
# install_weak_deps=False inside that image.
%if 0%{?rhel} == 9
Recommends:     tesseract
%else
Requires:       tesseract
%endif

Recommends:     ghostscript
Suggests:       exact-image

%description
pdfsandwich processes scanned PDF files with Tesseract and adds an invisible
text layer behind each page image. It supports preprocessing with unpaper,
parallel page processing, multiple OCR languages and configurable external
tools.

%prep
%autosetup -p1

%build
echo PREFIX=%{_prefix} > makefile.installprefix
%make_build all

%check
./pdfsandwich -version
bash tests/dependency-checks.sh

%install
%make_install PREFIX=%{_prefix} INSTALL=install install
rm -rf %{buildroot}%{_docdir}/%{name}

%files
%license LICENSE copyright
%doc README.md UPSTREAM_README.md UPSTREAM_SOURCE changelog
%{_bindir}/pdfsandwich
%{_mandir}/man1/pdfsandwich.1*

%changelog
* Wed Aug 05 2026 pdfsandwich maintenance project <noreply@github.com> - 0.1.7.1-1
- Import upstream 0.1.7 and add maintained packaging.
- Improve dependency diagnostics and ImageMagick 7 compatibility.
- Add Fedora and EL9 packaging for dual full-runtime container images.

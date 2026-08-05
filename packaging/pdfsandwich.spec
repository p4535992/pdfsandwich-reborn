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
Requires:       ImageMagick
Requires:       poppler-utils
Requires:       tesseract
Requires:       unpaper
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

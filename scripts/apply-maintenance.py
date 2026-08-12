#!/usr/bin/env python3
"""Apply the maintained pdfsandwich compatibility changes."""

from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "pdfsandwich.ml"
VERSION = ROOT / "pdfsandwich_version"
CHANGELOG = ROOT / "changelog"
MAINTAINED_VERSION = "0.1.8"

MAINTAINED_CHANGELOG = """pdfsandwich 0.1.8 (Wed, 12 Aug 2026 09:44:00 +0200):
\tmaintained pdfsandwich-reborn release based on verified upstream 0.1.7
\timproved dependency diagnostics and ImageMagick 7 command fallback
\treproducible source, Debian, Fedora and EL9 package builds
\tDebian/Temurin and Rocky/Alfresco full runtime images with license manifests
\tstandalone release Dockerfiles, installers and automated GitHub publishing

"""

ORIGINAL_CHECKS = r'''(*check if binary bin exists (in search path):*)
let check_for_binary bin =
\ttry
\tlet in_ch = Unix.open_process_in ("which " ^ bin) in
\tlet s = input_line in_ch in
\tif s = "" then failwith "";
\tignore (Unix.close_process_in in_ch);
\twith _ -> failwith 
\t\t("Could not find program " 
\t\t^ bin 
\t\t^ ". Make sure this program exists and can be found in your search path.\nUse command line options to specify a custom binary.")
;;
'''

MAINTAINED_CHECKS = r'''(* Return the executable part of a command which may include arguments. *)
let first_word command =
\tmatch Str.split (Str.regexp "[ \\t]+") command with
\t| [] -> command
\t| h::_ -> h
;;

(* Check if a command exists in PATH or is an executable path. *)
let command_exists command =
\tlet executable = first_word command in
\tSys.command ("command -v " ^ Filename.quote executable ^ " >/dev/null 2>&1") = 0
;;

let check_for_binary ?(required=true) bin debian_package rpm_package =
\tif not (command_exists bin) then
\t(
\t\tlet requirement = if required then "required" else "optional" in
\t\tlet message = Printf.sprintf
\t\t\t"Could not find %s program '%s'.\nInstall it with:\n  Debian/Ubuntu: sudo apt-get install %s\n  Fedora/RHEL-like: sudo dnf install %s\nYou can also select a custom executable with the corresponding pdfsandwich command-line option."
\t\t\trequirement bin debian_package rpm_package
\t\tin
\t\tif required then failwith message else prerr_endline ("Warning: " ^ message)
\t)
;;

(* ImageMagick 7 commonly installs `magick` without legacy aliases. *)
let maybe_use_imagemagick7 () =
\tif !convert = "convert" && not (command_exists !convert) && command_exists "magick" then
\t\tconvert := "magick";
\tif !identify = "identify" && not (command_exists !identify) && command_exists "magick" then
\t\tidentify := "magick identify"
;;
'''

ORIGINAL_DEPENDENCIES = r'''	List.iter check_for_binary [!convert; !tesseract; !gs; !pdfunite];
	if !enforcehocr2pdf then check_for_binary !hocr2pdf;
	if !preprocess then check_for_binary !unpaper;
'''

MAINTAINED_DEPENDENCIES = r'''	maybe_use_imagemagick7 ();
	check_for_binary !convert "imagemagick" "ImageMagick";
	check_for_binary ~required:false !identify "imagemagick" "ImageMagick";
	check_for_binary !tesseract "tesseract-ocr" "tesseract";
	check_for_binary !pdfinfo "poppler-utils" "poppler-utils";
	check_for_binary !pdfunite "poppler-utils" "poppler-utils";
	if !enforcehocr2pdf then
		check_for_binary !hocr2pdf "exactimage" "exact-image";
	if !preprocess then
		check_for_binary !unpaper "unpaper" "unpaper";
	if !pagesize <> "original" then
		check_for_binary !gs "ghostscript" "ghostscript"
	else
		check_for_binary ~required:false !gs "ghostscript" "ghostscript";
'''


def replace_once(text: str, old: str, new: str, description: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(
            f"Expected exactly one {description} block, found {count}. "
            "The upstream source may have changed."
        )
    return text.replace(old, new, 1)


def main() -> int:
    if not SOURCE.is_file():
        print(f"ERROR: source file not found: {SOURCE}", file=sys.stderr)
        return 2

    source_text = SOURCE.read_text(encoding="utf-8")
    source_text = replace_once(
        source_text,
        ORIGINAL_CHECKS,
        MAINTAINED_CHECKS,
        "dependency helper",
    )
    source_text = replace_once(
        source_text,
        ORIGINAL_DEPENDENCIES,
        MAINTAINED_DEPENDENCIES,
        "startup dependency check",
    )

    SOURCE.write_text(source_text, encoding="utf-8")
    upstream_changelog = CHANGELOG.read_text(encoding="utf-8")
    CHANGELOG.write_text(MAINTAINED_CHANGELOG + upstream_changelog, encoding="utf-8")
    VERSION.write_text(f"{MAINTAINED_VERSION}\n", encoding="utf-8")
    print(
        f"Applied maintained dependency diagnostics, ImageMagick 7 fallback and version {MAINTAINED_VERSION}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

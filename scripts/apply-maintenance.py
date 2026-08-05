#!/usr/bin/env python3
"""Apply the first maintained pdfsandwich compatibility changes.

The script intentionally uses exact source-block replacements. It aborts when
an expected upstream block is absent or occurs more than once, so an upstream
change cannot be patched silently in the wrong location.
"""

from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "pdfsandwich.ml"
VERSION = ROOT / "pdfsandwich_version"


ORIGINAL_CHECKS = r'''(*check if binary bin exists (in search path):*)
let check_for_binary bin =
	try
	let in_ch = Unix.open_process_in ("which " ^ bin) in
	let s = input_line in_ch in
	if s = "" then failwith "";
	ignore (Unix.close_process_in in_ch);
	with _ -> failwith 
		("Could not find program " 
		^ bin 
		^ ". Make sure this program exists and can be found in your search path.\nUse command line options to specify a custom binary.")
;;
'''

MAINTAINED_CHECKS = r'''(* Return the executable part of a command which may include arguments. *)
let first_word command =
	match Str.split (Str.regexp "[ \t]+") command with
	| [] -> command
	| h::_ -> h
;;

(* Check if a command exists in PATH or is an executable path. *)
let command_exists command =
	let executable = first_word command in
	Sys.command ("command -v " ^ Filename.quote executable ^ " >/dev/null 2>&1") = 0
;;

let check_for_binary ?(required=true) bin debian_package rpm_package =
	if not (command_exists bin) then
	(
		let requirement = if required then "required" else "optional" in
		let message = Printf.sprintf
			"Could not find %s program '%s'.\nInstall it with:\n  Debian/Ubuntu: sudo apt-get install %s\n  Fedora/RHEL-like: sudo dnf install %s\nYou can also select a custom executable with the corresponding pdfsandwich command-line option."
			requirement bin debian_package rpm_package
		in
		if required then failwith message else prerr_endline ("Warning: " ^ message)
	)
;;

(* ImageMagick 7 commonly installs `magick` without legacy aliases. *)
let maybe_use_imagemagick7 () =
	if !convert = "convert" && not (command_exists !convert) && command_exists "magick" then
		convert := "magick";
	if !identify = "identify" && not (command_exists !identify) && command_exists "magick" then
		identify := "magick identify"
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
    VERSION.write_text("0.1.7.1\n", encoding="utf-8")
    print("Applied maintained dependency diagnostics and ImageMagick 7 fallback.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

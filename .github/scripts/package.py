#!/usr/bin/env python3
"""Build a reproducible, directly loadable shader ZIP and checksum."""
import argparse
import hashlib
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]


def build(output):
    version = (ROOT / "VERSION").read_text().strip()
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise ValueError("VERSION must contain a release version such as 0.1.0")
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    archive = output / f"BurntToast_v{version}_.Chocapic13_Toaster_edit.zip"
    files = sorted(p for p in (ROOT / "shaders").rglob("*") if p.is_file())
    files += [ROOT / n for n in ("CREDITS.txt", "LICENSE.md", "README.md", "CHANGELOG.md", "VERSION")]
    if (ROOT / "LOCAL_ONLY.md").exists():
        files.append(ROOT / "LOCAL_ONLY.md")
    if (ROOT / "licenses").exists():
        files += [p for p in (ROOT / "licenses").rglob("*") if p.is_file()]
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as pack:
        for path in sorted(files):
            entry = zipfile.ZipInfo(path.relative_to(ROOT).as_posix(), (2026, 1, 1, 0, 0, 0))
            entry.compress_type = zipfile.ZIP_DEFLATED
            entry.external_attr = 0o100644 << 16
            entry.create_system = 3
            pack.writestr(entry, path.read_bytes(), compresslevel=9)
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix(".zip.sha256").write_text(f"{digest}  {archive.name}\n")
    return archive


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=ROOT / "dist")
    args = parser.parse_args()
    print(build(args.output))

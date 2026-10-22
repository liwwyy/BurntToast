#!/usr/bin/env python3
"""Optional headless directive check using an existing Iris JAR and Prism libraries."""
import argparse
import os
from pathlib import Path
import re
import subprocess

import validate

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--iris-jar", type=Path, required=True)
    parser.add_argument("--libraries", type=Path, required=True)
    args = parser.parse_args()
    jars = [args.iris_jar.resolve()]
    for dependency in ("it/unimi/dsi/fastutil", "org/joml/joml"):
        choices = list((args.libraries / dependency).glob("*/*.jar"))
        if not choices:
            parser.error(f"Missing {dependency} below {args.libraries}")
        jars.append(max(choices, key=lambda p: tuple(map(int, re.findall(r"\d+", p.parent.name)))).resolve())
    output = ROOT / ".build" / "iris-parser"
    output.mkdir(parents=True, exist_ok=True)
    sources = []
    for name in ("fallback", "world0", "world-1", "world1"):
        original = validate.SHADERS / ("" if name == "fallback" else name) / "composite.fsh"
        target = output / f"{name}.fsh"
        target.write_text(validate.expand(original))
        sources.append(str(target))
    classpath = os.pathsep.join(map(str, jars))
    subprocess.run(["javac", "-cp", classpath, "-d", str(output),
                    str(Path(__file__).with_name("IrisDirectiveCheck.java"))], check=True)
    subprocess.run(["java", "-cp", str(output) + os.pathsep + classpath,
                    "IrisDirectiveCheck", *sources], check=True)


if __name__ == "__main__":
    main()

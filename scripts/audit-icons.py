#!/usr/bin/env python3
r"""扫描 Lua 配置中的 Nerd Font 私用区(PUA)图标，并对照 Nerd Fonts v3 码点表检查是否失效。

背景：Nerd Fonts v3 迁移了大量旧码点（例如 Font Awesome Extension 从 E000-E0A9
移到 E200-E2A9），配置里写死的旧图标会变成方框。本脚本同时识别：
  - 字面量图标字符
  - Lua 十进制字节转义，如 "\238\128\158"
  - Lua 十六进制字节转义，如 "\xEE\x80\x9E"
  - Lua Unicode 转义，如 "\u{E01E}"

用法:
    python3 scripts/audit-icons.py lua
    python3 scripts/audit-icons.py lua --glyphnames /path/to/glyphnames.json
    python3 scripts/audit-icons.py lua --strict   # 有失效码点时退出码为 1

码点表下载:
    https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/glyphnames.json
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys

PUA_RANGES = (
    (0xE000, 0xF8FF),      # BMP PUA
    (0xF0000, 0xFFFFD),    # Supplementary PUA-A（MDI 等）
)

LIT_PUA = re.compile("[\uE000-\uF8FF\U000F0000-\U000FFFFD]")
DEC_RUN = re.compile(r"((?:\\[0-9]{1,3})+)")
HEX_RUN = re.compile(r"((?:\\x[0-9a-fA-F]{2})+)")
U_BRACE = re.compile(r"\\u\{([0-9a-fA-F]+)\}")
U_PLAIN = re.compile(r"\\u([0-9a-fA-F]{4})(?!\})")


def is_pua(cp: int) -> bool:
    return any(lo <= cp <= hi for lo, hi in PUA_RANGES)


def load_names(path: str | None) -> dict[int, str]:
    if not path:
        return {}
    try:
        data = json.load(open(path, encoding="utf-8"))
    except Exception as exc:
        print(f"warn: 无法读取码点表 {path}: {exc}", file=sys.stderr)
        return {}
    names = {}
    for key, value in data.items():
        if key == "METADATA" or not isinstance(value, dict):
            continue
        code = value.get("code")
        if isinstance(code, str):
            try:
                names[int(code, 16)] = key
            except ValueError:
                pass
    return names


def decode_bytes(raw: bytes) -> str:
    try:
        return raw.decode("utf-8")
    except UnicodeDecodeError:
        return ""


def codepoints(line: str) -> set[int]:
    cps = {ord(ch) for ch in LIT_PUA.findall(line)}

    for match in DEC_RUN.finditer(line):
        raw = bytes(int(x) for x in re.findall(r"\\([0-9]{1,3})", match.group(1)))
        cps.update(ord(ch) for ch in decode_bytes(raw) if is_pua(ord(ch)))

    for match in HEX_RUN.finditer(line):
        raw = bytes(int(x, 16) for x in re.findall(r"\\x([0-9a-fA-F]{2})", match.group(1)))
        cps.update(ord(ch) for ch in decode_bytes(raw) if is_pua(ord(ch)))

    for match in U_BRACE.finditer(line):
        cp = int(match.group(1), 16)
        if is_pua(cp):
            cps.add(cp)
    for match in U_PLAIN.finditer(line):
        cp = int(match.group(1), 16)
        if is_pua(cp):
            cps.add(cp)

    return cps


def find_glyphnames(explicit: str | None) -> str | None:
    candidates = [
        explicit,
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "glyphnames.json"),
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "glyphnames.json"),
        os.path.join(os.getcwd(), "glyphnames.json"),
    ]
    for path in candidates:
        if path and os.path.isfile(path):
            return os.path.abspath(path)
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description="扫描 Lua 配置中失效的 Nerd Font 图标")
    parser.add_argument("paths", nargs="*", default=["lua"], help="要扫描的目录（默认 lua）")
    parser.add_argument("--glyphnames", help="Nerd Fonts glyphnames.json 路径")
    parser.add_argument("--strict", action="store_true", help="存在失效码点时返回非 0")
    args = parser.parse_args()

    glyphnames = find_glyphnames(args.glyphnames)
    names = load_names(glyphnames)
    if not names:
        print(
            "提示: 未找到 glyphnames.json，无法判断码点是否属于 NF v3。\n"
            "     下载: curl -o glyphnames.json "
            "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/glyphnames.json",
            file=sys.stderr,
        )

    hits: dict[tuple[str, int], int] = {}
    for root in args.paths:
        if os.path.isfile(root):
            files = [root]
        else:
            files = [
                os.path.join(dirpath, filename)
                for dirpath, _, filenames in os.walk(root)
                for filename in filenames
                if filename.endswith(".lua")
            ]
        for path in files:
            for lineno, line in enumerate(
                open(path, encoding="utf-8", errors="replace"), 1
            ):
                # 跳过整行注释，避免把注释掉的图标算进来
                if line.lstrip().startswith("--"):
                    continue
                for cp in codepoints(line):
                    hits.setdefault((path, cp), lineno)

    if not hits:
        print("未发现 PUA 图标。")
        return 0

    print(f"{'file':<58}{'line':>6}  {'codepoint':<10}{'NFv3':<6}name")
    print("-" * 100)
    missing = []
    for (path, cp), lineno in sorted(hits.items(), key=lambda item: (item[0][0], item[1])):
        name = names.get(cp) if names else None
        if names and not name:
            missing.append((path, lineno, cp))
        status = ("yes" if name else "NO") if names else "?"
        print(
            f"{os.path.relpath(path):<58}{lineno:>6}  U+{cp:04X}    "
            f"{status:<6}{name or '-'}"
        )

    print(f"\n共 {len(hits)} 个 (文件, 码点) 组合。")
    if names:
        print(f"NF v3 中不存在: {len(missing)} 个")
    if missing and args.strict:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

"""Ambil hanya file Android dari Godot mono export templates (TPZ ~1.2 GB)
memakai HTTP range request via curl, supaya tidak perlu mengunduh seluruh paket.

Jalankan: python3 tools/fetch_android_templates.py
"""
import json
import os
import struct
import subprocess
import sys
import zlib

TAG = "4.7.2-stable"
ASSET_SUBSTRING = "mono_export_templates.tpz"
DEST = "/Users/ar/Library/Application Support/Godot/export_templates/4.7.2.stable.mono"
WANTED_SUFFIXES = (
    "android_source.zip",
    "android_debug.apk",
    "android_release.apk",
    "godot-lib.template_release.aar",
    "godot-lib.template_debug.aar",
)


def log(message: str) -> None:
    print(message, flush=True)


def curl(args: list[str], binary: bool = False):
    result = subprocess.run(
        ["curl", "-sS", "-L", "--fail", "--http1.1", "-m", "900"] + args, capture_output=True
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.decode("utf-8", "replace").strip() or "curl gagal")
    return result.stdout if binary else result.stdout.decode("utf-8", "replace")


def resolve_url() -> tuple[str, int]:
    api = f"https://api.github.com/repos/godotengine/godot-builds/releases/tags/{TAG}"
    payload = json.loads(curl(["-H", "User-Agent: godot-setup", api]))
    for asset in payload["assets"]:
        if ASSET_SUBSTRING in asset["name"]:
            return asset["browser_download_url"], asset["size"]
    raise SystemExit("asset tidak ditemukan")


def fetch_range(url: str, start: int, end: int, retries: int = 4) -> bytes:
    last_error: Exception | None = None
    for attempt in range(retries):
        try:
            return curl(
                [
                    "-H",
                    "User-Agent: godot-setup",
                    "-H",
                    "Accept: application/octet-stream",
                    "-r",
                    f"{start}-{end}",
                    url,
                ],
                binary=True,
            )
        except Exception as error:  # noqa: BLE001
            last_error = error
            log(f"  retry {attempt + 1}/{retries} ({error})")
    raise SystemExit(f"gagal mengambil range {start}-{end}: {last_error}")


def parse_central_directory(payload: bytes):
    entries = []
    offset = 0
    while payload[offset : offset + 4] == b"PK\x01\x02":
        method = struct.unpack_from("<H", payload, offset + 10)[0]
        compressed = struct.unpack_from("<I", payload, offset + 20)[0]
        uncompressed = struct.unpack_from("<I", payload, offset + 24)[0]
        name_len = struct.unpack_from("<H", payload, offset + 28)[0]
        extra_len = struct.unpack_from("<H", payload, offset + 30)[0]
        comment_len = struct.unpack_from("<H", payload, offset + 32)[0]
        local_offset = struct.unpack_from("<I", payload, offset + 42)[0]
        name = payload[offset + 46 : offset + 46 + name_len].decode("utf-8", "replace")
        extra = payload[offset + 46 + name_len : offset + 46 + name_len + extra_len]
        if compressed == 0xFFFFFFFF or uncompressed == 0xFFFFFFFF or local_offset == 0xFFFFFFFF:
            cursor = 0
            while cursor + 4 <= len(extra):
                field_id, field_len = struct.unpack_from("<HH", extra, cursor)
                body = extra[cursor + 4 : cursor + 4 + field_len]
                if field_id == 0x0001:
                    if uncompressed == 0xFFFFFFFF:
                        uncompressed = struct.unpack_from("<Q", body, 0)[0]
                    if compressed == 0xFFFFFFFF:
                        compressed = struct.unpack_from("<Q", body, 8)[0]
                    if local_offset == 0xFFFFFFFF:
                        local_offset = struct.unpack_from("<Q", body, 16)[0]
                cursor += 4 + field_len
        entries.append(
            {
                "name": name,
                "method": method,
                "compressed": compressed,
                "uncompressed": uncompressed,
                "local_offset": local_offset,
            }
        )
        offset += 46 + name_len + extra_len + comment_len
    return entries


def extract_entry(url: str, entry: dict) -> bytes:
    header = fetch_range(url, entry["local_offset"], entry["local_offset"] + 29)
    name_len = struct.unpack_from("<H", header, 26)[0]
    extra_len = struct.unpack_from("<H", header, 28)[0]
    data_start = entry["local_offset"] + 30 + name_len + extra_len
    raw = fetch_range(url, data_start, data_start + entry["compressed"] - 1)
    if entry["method"] == 0:
        return raw
    if entry["method"] == 8:
        return zlib.decompress(raw, -zlib.MAX_WBITS)
    raise SystemExit(f"metode kompresi tidak didukung: {entry['method']}")


def main() -> None:
    url, size = resolve_url()
    log(f"asset: {url}")
    log(f"ukuran TPZ: {size / 1e6:.1f} MB")

    tail_size = min(size, 1_048_576)
    tail = fetch_range(url, size - tail_size, size - 1)
    eocd_index = tail.rfind(b"PK\x05\x06")
    if eocd_index < 0:
        raise SystemExit("EOCD tidak ditemukan")
    cd_size = struct.unpack_from("<I", tail, eocd_index + 12)[0]
    cd_offset = struct.unpack_from("<I", tail, eocd_index + 16)[0]
    log(f"central directory: offset={cd_offset} size={cd_size}")

    entries = parse_central_directory(fetch_range(url, cd_offset, cd_offset + cd_size - 1))
    log(f"total entri: {len(entries)}")

    os.makedirs(DEST, exist_ok=True)
    for entry in entries:
        name = entry["name"]
        if not name.endswith(WANTED_SUFFIXES):
            continue
        target = os.path.join(DEST, os.path.basename(name))
        if os.path.exists(target) and os.path.getsize(target) == entry["uncompressed"]:
            log(f"lewati (sudah ada): {os.path.basename(name)}")
            continue
        log(f"mengunduh: {os.path.basename(name)} ({entry['uncompressed'] / 1e6:.1f} MB)")
        payload = extract_entry(url, entry)
        if len(payload) != entry["uncompressed"]:
            raise SystemExit(f"ukuran tidak cocok untuk {name}")
        with open(target, "wb") as handle:
            handle.write(payload)
        log(f"  tersimpan: {target}")
    log("TEMPLATES_DONE")


if __name__ == "__main__":
    sys.exit(main())

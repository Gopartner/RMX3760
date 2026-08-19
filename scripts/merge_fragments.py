#!/usr/bin/env python3
"""
Post-build vendor_boot v4 patcher for Unisoc UMS9230 devices.

Two jobs:
  1. Binary-patch cmdline at header offset 0x1C (2048-byte vendor cmdline
     field) to include "bootconfig bootconfig" tokens that mkbootimg
     parse_cmdline() rejects.  The bootloader reads cmdline from 0x1C
     (U-Boot android_vendor_boot_image_v3_v4_parse_hdr → hdr->cmdline)
     and concatenates it into bootargs.
  2. Merge vendor_ramdisk_table fragments from 2 → 1 PLATFORM entry
     (Unisoc bootloader only loads PLATFORM type fragments).

Usage:  python3 merge_fragments.py <vendor_boot.img>
"""
import struct
import sys
import os

VENDOR_RAMDISK_TYPE_PLATFORM = 1

# Full cmdline from stock vendor_boot. mkbootimg parse_cmdline() rejects
# the bare "bootconfig" tokens, so BOARD_VENDOR_CMDLINE only contains
# "console=ttyS1,115200n8". We patch the full string here post-build.
#
# vendor_boot v4 header layout (file offsets):
#   0x00  magic "VNDRBOOT" (8B)
#   0x08  header_version   0x0C  page_size       0x10  kernel_addr
#   0x14  ramdisk_addr     0x18  vendor_ramdisk_size
#   0x1C  cmdline[2048]    ← THIS field (vendor kernel cmdline)
#   0x81C tags_addr        0x820 name[16]        0x830 header_size
#   0x834 dtb_size         0x838 dtb_addr(8B)    0x840 vrt_size
#   0x844 vrt_entry_num    0x848 vrt_entry_size  0x84C bootconfig_size
VENDOR_CMDLINE_FULL = b"console=ttyS1,115200n8 bootconfig bootconfig"
CMDLINE_OFFSET = 0x1C
CMDLINE_BUF_SIZE = 2048


def patch_cmdline(data):
    """Write full cmdline (with bootconfig tokens) into vendor_boot header at 0x1C."""
    current = data[CMDLINE_OFFSET:CMDLINE_OFFSET + CMDLINE_BUF_SIZE].split(b"\x00")[0]
    print(f"=== cmdline @ 0x{CMDLINE_OFFSET:x} (2048B vendor cmdline field) ===")
    print(f"  current: [{current.decode(errors='replace')}]")
    print(f"  patching to: [{VENDOR_CMDLINE_FULL.decode()}]")
    data[CMDLINE_OFFSET:CMDLINE_OFFSET + CMDLINE_BUF_SIZE] = b"\x00" * CMDLINE_BUF_SIZE
    data[CMDLINE_OFFSET:CMDLINE_OFFSET + len(VENDOR_CMDLINE_FULL)] = VENDOR_CMDLINE_FULL
    print(f"  cmdline patched ({len(VENDOR_CMDLINE_FULL)} bytes written)")


def merge_fragments(data):
    """Merge vendor_ramdisk_table from 2+ entries → 1 PLATFORM entry."""
    page_size = struct.unpack_from("<I", data, 0x0C)[0]
    vendor_ramdisk_size = struct.unpack_from("<I", data, 0x18)[0]
    header_size = struct.unpack_from("<I", data, 0x830)[0]
    dtb_size = struct.unpack_from("<I", data, 0x834)[0]
    vrt_size = struct.unpack_from("<I", data, 0x840)[0]
    vrt_entry_num = struct.unpack_from("<I", data, 0x844)[0]
    vrt_entry_size = struct.unpack_from("<I", data, 0x848)[0]

    print(f"\n=== vendor_boot v4 header ===")
    print(f"  page_size:           {page_size}")
    print(f"  header_size:         {header_size}")
    print(f"  vendor_ramdisk_size: {vendor_ramdisk_size}")
    print(f"  dtb_size:            {dtb_size}")
    print(f"  vrt_size:            {vrt_size}")
    print(f"  vrt_entry_num:       {vrt_entry_num}")
    print(f"  vrt_entry_size:      {vrt_entry_size}")

    if vrt_entry_num <= 1:
        print(f"\nAlready {vrt_entry_num} fragment(s) — no merge needed.")
        return

    def pages(size):
        return (size + page_size - 1) // page_size

    hdr_pages = pages(header_size)
    ramdisk_pages = pages(vendor_ramdisk_size)
    dtb_pages = pages(dtb_size)
    vrt_offset = (hdr_pages + ramdisk_pages + dtb_pages) * page_size

    print(f"\n=== section offsets ===")
    print(f"  header:         0x000000  ({hdr_pages} pages)")
    print(f"  vendor_ramdisk: 0x{hdr_pages * page_size:06x}  ({ramdisk_pages} pages)")
    print(f"  dtb:            0x{(hdr_pages + ramdisk_pages) * page_size:06x}  ({dtb_pages} pages)")
    print(f"  vrt:            0x{vrt_offset:06x}")

    entries = []
    for i in range(vrt_entry_num):
        off = vrt_offset + i * vrt_entry_size
        e_size = struct.unpack_from("<I", data, off)[0]
        e_offset = struct.unpack_from("<I", data, off + 4)[0]
        e_type = struct.unpack_from("<I", data, off + 8)[0]
        e_name = data[off + 12 : off + 44].split(b"\x00")[0].decode()
        entries.append((e_size, e_offset, e_type, e_name))

        type_names = {0: "NONE", 1: "PLATFORM", 2: "RECOVERY", 3: "DLKM"}
        print(f"\n  Entry {i}:")
        print(f"    ramdisk_size:   {e_size} (0x{e_size:x})")
        print(f"    ramdisk_offset: {e_offset}")
        print(f"    ramdisk_type:   {e_type} ({type_names.get(e_type, '?')})")
        print(f"    ramdisk_name:   [{e_name}]")

    total_size = sum(e[0] for e in entries)
    print(f"\n  Total vendor ramdisk from entries: {total_size}")

    struct.pack_into("<I", data, vrt_offset + 0, vendor_ramdisk_size)
    struct.pack_into("<I", data, vrt_offset + 4, 0)
    struct.pack_into("<I", data, vrt_offset + 8, VENDOR_RAMDISK_TYPE_PLATFORM)

    for i in range(1, vrt_entry_num):
        off = vrt_offset + i * vrt_entry_size
        for j in range(vrt_entry_size):
            data[off + j] = 0

    struct.pack_into("<I", data, 0x844, 1)
    struct.pack_into("<I", data, 0x840, vrt_entry_size)

    print(f"\n=== FRAGMENTS MERGED ===")
    print(f"  1 PLATFORM entry covering {vendor_ramdisk_size} bytes (0x{vendor_ramdisk_size:x})")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <vendor_boot.img>")
        sys.exit(1)

    img_path = sys.argv[1]
    with open(img_path, "r+b") as f:
        data = bytearray(f.read())

    magic = data[0:8]
    if magic != b"VNDRBOOT":
        print(f"ERROR: not a vendor_boot image (magic={magic!r})")
        sys.exit(1)

    header_version = struct.unpack_from("<I", data, 0x08)[0]
    if header_version != 4:
        print(f"ERROR: header version {header_version}, expected 4")
        sys.exit(1)

    patch_cmdline(data)
    merge_fragments(data)

    with open(img_path, "wb") as f:
        f.write(data)

    print(f"\n=== DONE ===")
    print(f"  Image rewritten: {img_path}")
    print(f"  File size: {os.path.getsize(img_path)} bytes")

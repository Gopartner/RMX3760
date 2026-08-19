#!/usr/bin/env python3
"""
Merge vendor_boot v4 ramdisk fragments from 2 → 1 PLATFORM entry.

Unisoc UMS9230 bootloader only loads PLATFORM type fragments from the
vendor_ramdisk_table.  Stock vendor_boot uses 1 PLATFORM entry.  The
TWRP build system creates 2 entries (PLATFORM + RECOVERY) for header v4.
This script merges them into a single PLATFORM entry post-build so the
Unisoc bootloader loads the entire ramdisk section correctly.

Usage:  python3 merge_fragments.py <vendor_boot.img>
"""
import struct
import sys
import os

VENDOR_RAMDISK_TYPE_PLATFORM = 1
VENDOR_RAMDISK_TYPE_RECOVERY = 2


def merge_fragments(img_path):
    with open(img_path, "r+b") as f:
        data = bytearray(f.read())

    # --- parse header ---------------------------------------------------
    magic = data[0:8]
    if magic != b"VNDRBOOT":
        print(f"ERROR: not a vendor_boot image (magic={magic!r})")
        sys.exit(1)

    header_version = struct.unpack_from("<I", data, 0x08)[0]
    if header_version != 4:
        print(f"ERROR: header version {header_version}, expected 4")
        sys.exit(1)

    page_size = struct.unpack_from("<I", data, 0x0C)[0]
    vendor_ramdisk_size = struct.unpack_from("<I", data, 0x18)[0]
    header_size = struct.unpack_from("<I", data, 0x830)[0]
    dtb_size = struct.unpack_from("<I", data, 0x834)[0]
    vrt_size = struct.unpack_from("<I", data, 0x840)[0]
    vrt_entry_num = struct.unpack_from("<I", data, 0x844)[0]
    vrt_entry_size = struct.unpack_from("<I", data, 0x848)[0]

    print(f"=== vendor_boot v4 header ===")
    print(f"  page_size:              {page_size}")
    print(f"  header_size:            {header_size}")
    print(f"  vendor_ramdisk_size:    {vendor_ramdisk_size}")
    print(f"  dtb_size:               {dtb_size}")
    print(f"  vrt_size:               {vrt_size}")
    print(f"  vrt_entry_num:          {vrt_entry_num}")
    print(f"  vrt_entry_size:         {vrt_entry_size}")

    if vrt_entry_num <= 1:
        print(f"\nAlready {vrt_entry_num} fragment(s) — no merge needed.")
        return

    # --- calculate section offsets --------------------------------------
    def pages(size):
        return (size + page_size - 1) // page_size

    hdr_pages = pages(header_size)
    ramdisk_pages = pages(vendor_ramdisk_size)
    dtb_pages = pages(dtb_size)
    vrt_offset = (hdr_pages + ramdisk_pages + dtb_pages) * page_size

    print(f"\n=== section offsets ===")
    print(f"  header:       0x000000  ({hdr_pages} pages)")
    print(f"  vendor_ramdisk: 0x{hdr_pages * page_size:06x}  ({ramdisk_pages} pages)")
    print(f"  dtb:          0x{(hdr_pages + ramdisk_pages) * page_size:06x}  ({dtb_pages} pages)")
    print(f"  vrt:          0x{vrt_offset:06x}  (1 page)")

    # --- parse existing entries -----------------------------------------
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

    # --- merge ----------------------------------------------------------
    total_size = sum(e[0] for e in entries)
    print(f"\n  Total vendor ramdisk from entries: {total_size}")

    # Verify alignment: the fragments are concatenated in the vendor ramdisk
    # section.  Fragment i starts at entry[i].ramdisk_offset within the
    # section.  The total section size must equal vendor_ramdisk_size.
    # If total_size < vendor_ramdisk_size there is padding between fragments.
    # We keep the existing vendor_ramdisk_size unchanged to preserve padding.

    # Write merged entry (single PLATFORM covering the entire section)
    struct.pack_into("<I", data, vrt_offset + 0, vendor_ramdisk_size)  # ramdisk_size = full section
    struct.pack_into("<I", data, vrt_offset + 4, 0)                    # ramdisk_offset = 0
    struct.pack_into("<I", data, vrt_offset + 8, VENDOR_RAMDISK_TYPE_PLATFORM)  # type = PLATFORM

    # Zero out remaining entries
    for i in range(1, vrt_entry_num):
        off = vrt_offset + i * vrt_entry_size
        for j in range(vrt_entry_size):
            data[off + j] = 0

    # Update header
    struct.pack_into("<I", data, 0x844, 1)      # vrt_entry_num = 1
    struct.pack_into("<I", data, 0x840, vrt_entry_size)  # vrt_size = 108

    # --- write back -----------------------------------------------------
    with open(img_path, "wb") as f:
        f.write(data)

    print(f"\n=== MERGED ===")
    print(f"  1 PLATFORM entry covering {vendor_ramdisk_size} bytes (0x{vendor_ramdisk_size:x})")
    print(f"  vrt_entry_num updated: {vrt_entry_num} → 1")
    print(f"  vrt_size updated: {vrt_size} → {vrt_entry_size}")
    print(f"  Image rewritten: {img_path}")
    print(f"  File size: {os.path.getsize(img_path)} bytes")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <vendor_boot.img>")
        sys.exit(1)
    merge_fragments(sys.argv[1])

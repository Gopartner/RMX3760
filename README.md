# TWRP Recovery — Realme C53 (RMX3760)

Custom TWRP 12.1 recovery untuk Realme C53 / RMX3760 berbasis Unisoc UMS9230 (T612), Android 15 (AP3A). Build otomatis via GitHub Actions, output berupa `vendor_boot` image (boot header v4).

## Spesifikasi Device

| Komponen | Nilai |
|---|---|
| SoC | Unisoc UMS9230 (T612) |
| Board | `ums9230_hulk` |
| Android | 15 (SDK 35) |
| Security patch | 2026-05-01 |
| Boot header | v4 (Virtual A/B) |
| Filesystem | erofs (system/vendor/product), f2fs (data) |
| Encryption | FBE v2, keymaster + gatekeeper trusty |
| Slot aktif | B (A/B device) |

## Build

1. Fork repository ini ke akun GitHub kamu.
2. Tab **Actions** → workflow **Build TWRP RMX3760 Android 15** → **Run workflow**.
3. Tunggu 15-30 menit. Artifact `twrp_vendor_boot.img` tersedia di bagian bawah halaman workflow yang selesai.

### Apa yang dilakukan workflow

```
build/envsetup.sh → lunch twrp_RMX3760-eng → mka vendorbootimage
    ↓
merge_fragments.py
    ├─ Patch cmdline (offset 0x1C): tambah "bootconfig bootconfig" tokens
    └─ Merge vendor_ramdisk_table: 2 entry → 1 PLATFORM entry (Unisoc fix)
    ↓
Artifact: twrp_vendor_boot.img
```

Patch `graphics_drm.cpp` diterapkan otomatis sebelum build untuk mengganti `drmModeAtomicCommit` (Qualcomm) dengan legacy `drmModeSetCrtc` + `drmModePageFlip` yang kompatibel dengan DRM driver Unisoc.

## Flash

```bash
adb reboot bootloader
fastboot flash vendor_boot_b twrp_vendor_boot.img
fastboot reboot recovery
```

Pastikan slot sesuai `fastboot getvar current-slot`. Device ini menggunakan slot B.

> **Catatan penting:** `fastboot boot` tidak didukung di device ini. Harus flash permanen ke `vendor_boot_b`.

## Restore Stock

Simpan backup `vendor_boot_a.img` dan `vendor_boot_b.img` dari stock sebelum flash TWRP.

```bash
adb reboot bootloader
fastboot flash vendor_boot_a vendor_boot_a.img
fastboot flash vendor_boot_b vendor_boot_b.img
fastboot reboot recovery
```

Jika device terjebak di recovery setelah flash gagal:

```bash
fastboot erase misc
fastboot reboot
```

Jika bootloop persisten, flash vbmeta stock kembali:

```bash
fastboot flash vbmeta_b vbmeta_b.img
fastboot flash vbmeta_vendor_b vbmeta_vendor_b.img
fastboot erase misc
fastboot reboot
```

## Spesifikasi Partisi

| Partisi | Ukuran | File system |
|---|---|---|
| boot | 64 MB | — |
| init_boot | 8 MB | — |
| vendor_boot | 100 MB | — |
| super | 8000 MB | dynamic |
| metadata | 64 MB | f2fs |
| userdata | 128 GB+ | f2fs (FBE v2) |

## Struktur Vendor Boot v4

```
+---------------------------+  0x00
| magic "VNDRBOOT" (8B)    |
| header_version = 4        |
| page_size = 4096          |
| kernel_addr = 0x8000      |
| ramdisk_addr = 0x5400000  |
| vendor_ramdisk_size       |
| cmdline[2048] @ 0x1C      |  ← "console=ttyS1,115200n8 bootconfig bootconfig"
| tags_addr = 0x100         |
| header_size = 2128        |
| dtb_size = 134558         |
| dtb_addr = 0x1F00000      |
| vrt (3 × 12B)            |
| bootconfig_size = 57      |
+---------------------------+  0x1000 (page 1)
| vendor ramdisk (erofs)    |  ← recovery ramdisk + modules
+---------------------------+
| DTB (134558 bytes)        |  ← prebuilt/dtb (binary match stock)
+---------------------------+
| vendor_ramdisk_table      |  ← 1 PLATFORM entry
+---------------------------+
| bootconfig (57 bytes)     |  ← androidboot.hardware=ums9230_hulk
+---------------------------+
```

## Konfigurasi TWRP

| Parameter | Nilai |
|---|---|
| Theme | portrait_hdpi |
| Crypto | FBE v2 (metadata partition) |
| Vendor modules | 89 modules (load via `TW_LOAD_VENDOR_MODULES`) |
| Bootconfig | 57 bytes (`androidboot.hardware=ums9230_hulk`, `androidboot.dtbo_idx=0`) |
| AVB | `--flags 0` (verification enabled, unlocked bootloader tolerates mismatch) |
| SELinux | Permissive (recovery mode) |

## Troubleshooting

### Build gagal: "No config file found for TARGET_DEVICE"
Pastikan `PRODUCT_DEVICE := RMX3760` di `twrp_RMX3760.mk` sesuai nama folder device tree.

### Build gagal: "parse_cmdline: unrecognized argument 'bootconfig'"
Normal. Token `bootconfig` ditolak oleh mkbootimg. Script `merge_fragments.py` menambahkannya secara binary post-build ke offset 0x1C.

### Device bootloop setelah flash
1. Boot ke fastboot: `adb reboot bootloader`
2. Flash vendor_boot stock: `fastboot flash vendor_boot_b vendor_boot_b.img`
3. Clear misc: `fastboot erase misc`
4. Reboot: `fastboot reboot`

### UI mati / "Atomic commit failed ret=-22"
Patch `graphics_drm.cpp` sudah diterapkan otomatis oleh workflow. Jika masih terjadi, pastikan file `issue_atomic/graphics_drm.cpp` ada di repository.

### Data tidak ter-decrypt
Pastikan `device.mk` menyertakan crypto HAL packages (`keymaster@4.0-service.trusty`, `gatekeeper@1.0-service.trusty`). FBE v2 membutuhkan trusted HAL untuk decrypt key.

## Catatan Teknis

- **Cmdline injection:** mkbootimg menolak token `bootconfig` (parse_cmdline). Script `merge_fragments.py` menulis ulang field cmdline di offset 0x1C secara binary setelah build. Bootloader (U-Boot) membaca field ini dari `hdr->cmdline` dan menggabungkannya ke `bootargs`.
- **Fragment merge:** Unisoc bootloader hanya memuat vendor ramdisk dengan type `PLATFORM`. TWRP default membangun 2 entry (PLATFORM + RECOVERY). Script merge menggabungkannya menjadi 1 entry PLATFORM.
- **DTB:** Binary `prebuilt/dtb` diambil langsung dari dump stock (134558 bytes). Tidak dimodifikasi.
- **Modules:** 89 kernel modules di-sync dari device live (`/vendor/lib/modules`), vermagic `5.15.178-android13-8-g0c749b198e8d-ab40`.

# TWRP Device Tree — Realme C53 / RMX3760 (UMS9230 / T612) — Android 15

> Status: **build via GitHub Actions, flash via fastboot**. Patch `graphics_drm.cpp` diterapkan otomatis di workflow (fix `Atomic commit failed ret=-22` / UI mati).

## Build (GitHub Actions)

1. Pastikan repo ini di-fork ke akun kamu.
2. **Actions** tab → **Build TWRP RMX3760 Android 15** → **Run workflow**.
3. Tunggu ± 15–30 menit. Hasil: artifact `twrp_vendor_boot.img` (bisa ambil di Actions → paling bawah → Artifacts).

## Flash ke device (slot aktif = B)

```bat
adb reboot bootloader
fastboot flash vendor_boot_b twrp_vendor_boot.img
fastboot reboot recovery
```

> Pastikan slot sesuai `fastboot getvar current-slot`. Karena kamu di slot B, pakai flash `vendor_boot_b`.
> ⚠️ `fastboot boot` TIDAK didukung di device ini (fallback ke system) — harus flash permanen dahulu.

## Restore stock (kalau bootloop / mau balik)

```bat
adb reboot bootloader
fastboot flash vendor_boot_a vendor_boot_a.img   // dari dump stock C:\RMX3760
fastboot flash vendor_boot_b vendor_boot_b.img   // dari dump stock C:\RMX3760
fastboot reboot recovery
```

Rekomendasi: **simpan dulu stock `vendor_boot_a.img` & `vendor_boot_b.img`** (sudah ada di `C:\RMX3760\`) sebelum flash TWRP. TWRP mengganti vendor_boot — tanpa backup, kalau bootloop kamu kesulitan.

## Partisi / nilai dari dump stock

| Item | Nilai |
|------|-------|
| Boot header | v4 (`header_size=1584`/2128) |
| Kernel | di `boot_a/b` (ramdisk 0) |
| Init ramdisk | di `init_boot_a/b` |
| Recovery ramdisk | di dalam `vendor_boot` (vendor ramdisk + DTB) |
| `dtb_size` | 134558 (@ `prebuilt/dtb`) |
| page_size | 4096 |
| kernel_addr / ramdisk_addr / tags / dtb | 0x8000 / 0x5400000 / 0x100 / 0x1f00000 |
| cmdline | `console=ttyS1,115200n8` (token `bootconfig` dibuang: mkbootimg menolaknya & kernel tidak memakainya) |
| Partition size | `vendor_boot` 104857600, `boot` 67108864, `init_boot` 8388608 |
| Super | 8388608000 (group `realme_dynamic_partitions`) |
| FS | system/vendor/product/odm erofs, data f2fs |

## Cek kepemilikan modul yang benar

- Modul kernel (`recovery/root/lib/modules/*.ko`) di-sync dari **device live** (`/vendor/lib/modules`, vendor_dlkm, vermagic `5.15.178-android13-8-g0c749b198e8d-ab40`) supaya pas dengan kernel yang boot (slot B). Modul yang dibuilt-in di kernel ab40 (contoh: `ufs_sprd.ko`, `sdhci-sprd.ko`, `clk-sprd.ko`) dihapus dari ramdisk.
- `modules.load.recovery` = subset recovery (display/touch/USB/battery) dengan urutan dependensi dari `modules.dep` ab40.
- Bootconfig stock 57B dipertahankan sebagai `prebuilt/vendor_bootconfig` via `--vendor_bootconfig`.

## Catatan decryption

- FBE v2 (`fscrypt_policy`, metadata partition). Untuk decrypt data perlu keymaster/gatekeeper trusty HAL (`android.hardware.keymaster*` + gatekeeper trusty). Saat ini `device.mk` belum menyertakan paketnya — kalau data tidak decrypt, tambahkan dari template cooked71.
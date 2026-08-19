#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 TWRP device tree generator
#
# Realme C53 / RMX3760 (UMS9230 / T612) - Android 15
# Boot header v4, virtual A/B. Values sourced from stock vendor_boot_a.img dump:
#   page_size=4096 kernel_addr=0x8000 ramdisk_addr=0x5400000 tags=0x100
#   header_size=2128 dtb_size=134558 dtb_addr=0x1f00000 vendor_ramdisk_size=36105757

DEVICE_PATH := device/realme/RMX3760

# Build Hack
BUILD_BROKEN_DUP_RULES := true
ALLOW_MISSING_DEPENDENCIES := true

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    init_boot \
    vendor_boot \
    dtbo \
    system \
    system_ext \
    product \
    vendor \
    odm \
    vendor_dlkm \
    system_dlkm \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a75

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := ums9230_hulk
TARGET_NO_BOOTLOADER := true

TARGET_SCREEN_DENSITY := 320
TARGET_OTA_ASSERT_DEVICE := RMX3760

# Kernel
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64

# No kernel in our TWRP image - kernel stays in stock boot partition.
# We only ship a recovery ramdisk inside vendor_boot.
TARGET_NO_KERNEL := true
BOARD_RAMDISK_USE_LZ4 := true
BOARD_KERNEL_SEPARATED_DTBO := true

# Prebuilt DTB extracted from stock dump (DTBO-table format, dtb_size=134558)
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb
BOARD_DTB_SIZE := 134558

BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true

BOARD_BOOT_HEADER_VERSION := 4
BOARD_BUILD_INIT_BOOT_HEADER_VERSION := 4
BOARD_INIT_BOOT_HEADER_VERSION := 4

BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_PAGE_SIZE := 4096
BOARD_RAMDISK_OFFSET := 0x05400000
BOARD_TAGS_OFFSET := 0x00000100
BOARD_DTB_OFFSET := 0x01f00000
BOARD_HEADER_SIZE := 2128

# Stock vendor_boot v4 cmdline — exact copy from stock vendor_boot_a/b.
# "bootconfig bootconfig" tokens tell the kernel to parse the bootconfig
# section (androidboot.hardware, androidboot.dtbo_idx, etc.) appended
# after initrd by the bootloader (U-Boot android_image_get_kernel).
# mkbootimg parse_cmdline() rejects "bootconfig" as unrecognized arg, so
# the full cmdline (with tokens) is injected post-build by merge_fragments.py
# into the cmdline field at header offset 0x1C (ANDR_VENDOR_BOOT_ARGS_SIZE=2048).
BOARD_VENDOR_CMDLINE := console=ttyS1,115200n8

# Exact Android 15 vendor_boot v4 bootconfig (57 bytes) from stock
# vendor_boot_a/b. Provided as a raw prebuilt payload via --vendor_bootconfig
# (BOARD_BOOTCONFIG is not wired into TWRP 12.1's vendorbootimage build).
BOARD_BOOTCONFIG :=

BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)
BOARD_MKBOOTIMG_ARGS += --vendor_bootconfig $(DEVICE_PATH)/prebuilt/vendor_bootconfig
BOARD_MKBOOTIMG_ARGS += --vendor_cmdline $(BOARD_VENDOR_CMDLINE)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_PAGE_SIZE) --board ""
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144

BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 104857600

BOARD_HAS_LARGE_FILESYSTEM := true

TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

BOARD_USES_PRODUCTIMAGE := true
BOARD_USES_SYSTEM_EXTIMAGE := true
BOARD_USES_ODMIMAGE := true
BOARD_USES_VENDOR_DLKMIMAGE := true

BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EROFS := true

BOARD_SUPER_PARTITION_SIZE := 8388608000
BOARD_SUPER_PARTITION_GROUPS := realme_dynamic_partitions

BOARD_REALME_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_ext \
    vendor \
    odm \
    product \
    vendor_dlkm

BOARD_REALME_DYNAMIC_PARTITIONS_SIZE := 8384413696

TARGET_BOARD_PLATFORM := ums9230

# Verified Boot
BOARD_AVB_ENABLE := true
# NOTE: --flags 3 TIDAK BEKERJA di Unisoc. Bootloader validates vbmeta
# signature BEFORE reading flags. Rebuilt vbmeta (AOSP test key) → invalid
# signature → bootloop. Keep OEM vbmeta unmodified. When bootloader unlocked,
# vendor_boot hash mismatch is tolerated. User harus:
# 1. Flash TWRP vendor_boot (fastboot flash vendor_boot_b twrp_vendor_boot.img)
# 2. JANGAN flash vbmeta baru — keep OEM vbmeta
# 3. Jika masih bootloop, gunakan UnisocBypass untuk patch uboot
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 0

# NOTE: This device has NO vbmeta_vendor_boot partition (confirmed via
# /dev/block/by-name on the live device). BoardConfig previously referenced
# $(DEVICE_PATH)/vbmeta_vendor_boot.img which does not exist in the tree and
# would fail the build. The stock vendor_boot_a.img carries a plain AVB hash
# footer (AVBf @ 104857536), which the AOSP build adds automatically because
# BOARD_AVB_ENABLE is set. With an unlocked bootloader + vbmeta --flags 3
# (verification/hash disabled), AVB is relaxed anyway.

# Hack: prevent anti rollback issues during TWRP build
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := 2099-12-31
PLATFORM_VERSION := 16.1.0

# Vendor API level = Android 13 (ro.vendor.build.version.sdk=33)
BOARD_VENDOR_API_LEVEL := 33

# Recovery
TARGET_NO_RECOVERY := true
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := \
    $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab

# init_boot remains stock: vendor_boot supplies only the recovery ramdisk.

# TWRP Configuration
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_INPUT_BLACKLIST := "hbtp_vm"

TW_USE_TOOLBOX := true
TW_INCLUDE_REPACKTOOLS := true

TW_HAS_NO_RECOVERY_PARTITION := true

# Crypto (fbe v2, metadata partition)
BOARD_USES_METADATA_PARTITION := true
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_USE_FSCRYPT_POLICY := 2

TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_RESETPROP := true

TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true

TARGET_RECOVERY_DEVICE_MODULES += \
    libbinder_ndk \
    libc++ \
    libbase \
    libcutils \
    libutils

BOARD_VNDK_VERSION := current

TW_LOAD_VENDOR_BOOT_MODULES := true

LIB_MODULES := $(wildcard $(DEVICE_PATH)/recovery/root/lib/modules/*.ko)

BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(LIB_MODULES)

BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
    $(DEVICE_PATH)/recovery/root/lib/modules/modules.load.recovery

# TW_LOAD_VENDOR_MODULES is a build flag (#ifdef), NOT a module list.
# A multi-line list here gets split into separate clang args and breaks the build.
TW_LOAD_VENDOR_MODULES := true
#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/realme/RMX3760

# Dynamic Partitions Setup
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# VNDK / SDK
TARGET_SUPPORTS_VNDK := true
BOARD_VNDK_VERSION := current

PRODUCT_PLATFORM := ums9230

# Virtual A/B OTA & Compression
ENABLE_VIRTUAL_AB := true
PRODUCT_VIRTUAL_AB_COMPRESSION := true

# A/B Partitions Configuration
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    init_boot \
    l_agdsp \
    l_deltanv \
    l_fixnv1 \
    l_fixnv2 \
    l_gdsp \
    l_ldsp \
    l_modem \
    odm \
    pm_sys \
    product \
    sdc \
    sml \
    system \
    system_ext \
    teecfg \
    trustos \
    uboot \
    vbmeta \
    vbmeta_odm \
    vbmeta_product \
    vbmeta_system \
    vbmeta_system_ext \
    vbmeta_vendor \
    vendor \
    vendor_boot \
    vendor_dlkm

# Update Engine & Postinstall Setup
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true

# Boot Control HAL 1.2 (Unisoc UMS9230)
# Follows the UMIDIGI A15C (UMS9230 family) TWRP 12.1 tree for the build
# closure. Module names verified against the actual CI manifest repos
# (LineageOS android_hardware_interfaces lineage-19.1 boot/1.2/default/Android.bp):
# only android.hardware.boot@1.2-impl (stem android.hardware.boot@1.0-impl-1.2,
# recovery_available) and android.hardware.boot@1.2-service exist.
# The A15C "android.hardware.boot@1.2-impl-recovery" entry names a module that
# does not exist anywhere in the manifest and is therefore dropped (it would
# be silently skipped under ALLOW_MISSING_DEPENDENCIES anyway).
# bootctrl.ums9230(.recovery) are kept for A15C parity; no manifest repo
# provides them, so they are no-ops at build time. Runtime A/B boot control is
# served by the STOCK passthrough impl hw/android.hardware.boot@1.0-impl-1.2.so
# (wholesale-copied from the Android 15 vendor_boot, self-contained Unisoc
# boot control, linked against the stock libc++/libc/libm trio).
# The stock Android 15 AIDL boot service
# (vendor.sprd.hardware.boot-service.default_recovery) is handled separately
# via its rc + vintf manifest below.
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-service \
    bootctrl.ums9230 \
    bootctrl.ums9230.recovery

PRODUCT_PACKAGES_DEBUG += \
    bootctrl \
    update_engine_client

# Health HAL
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# Fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    android.hardware.fastboot@1.0-impl-mock.recovery \
    fastbootd

# VINTF Manifests & Non-ELF Scripts (Gunakan varian Unisoc Sprd)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/etc/vintf/manifest/vendor.sprd.hardware.boot-service.default.xml:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/vintf/manifest/vendor.sprd.hardware.boot-service.default.xml \
    $(LOCAL_PATH)/recovery/root/system/bin/create_splloader_dual_slot_byname_path.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/create_splloader_dual_slot_byname_path.sh \
    $(LOCAL_PATH)/recovery/root/system/etc/init/vendor.sprd.hardware.boot-service.default_recovery.rc:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/init/vendor.sprd.hardware.boot-service.default_recovery.rc \
    $(LOCAL_PATH)/recovery/root/system/etc/init/servicemanager.recovery.rc:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/init/servicemanager.recovery.rc

# Stock Android 15 bionic, restored from vb_stock/ramdisk/system/lib64
# (SHA256-identical). The recovery binary, the stock boot HAL impl
# (hw/android.hardware.boot@1.0-impl-1.2.so) and the vendor.sprd AIDL boot
# service resolve libc++/libc/libm against these stock copies in /system/lib64,
# which keeps the runtime self-consistent and provides __libcpp_verbose_abort
# (the symbol that the earlier AOSP libc++ did not export, which crashed
# android.hardware.boot@1.1.so during dynamic linking).

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/lib64/libc++.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libc++.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libc.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libc.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libm.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libm.so

# Bootconfig injection (vendor ramdisk root + recovery ramdisk root)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/bootconfig:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/bootconfig \
    $(LOCAL_PATH)/bootconfig:$(TARGET_COPY_OUT_RECOVERY)/root/bootconfig

# Boot HAL client libraries android.hardware.boot@1.0/1.1/1.2 are provisioned
# by the build: TWRP 12.1 recovery links all three via LOCAL_SHARED_LIBRARIES
# and, with AB_OTA_UPDATER=true, TWRP_REQUIRED_MODULES bundles the matching
# @1.0/@1.1/@1.2 boot HAL services into the recovery ramdisk.
# The previous injection of stock Android 15 @1.0.so/@1.2.so (without the
# matching @1.1.so) produced the mixed runtime that crashed in
# __libcpp_verbose_abort on android.hardware.boot@1.1.so; the build closure
# supplies a self-consistent @1.0/@1.1/@1.2 set instead.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/lib64/android.hardware.boot-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/android.hardware.boot-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/android.hardware.boot@1.0.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/android.hardware.boot@1.0.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/android.hardware.boot@1.1.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/android.hardware.boot@1.1.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/android.hardware.boot@1.2.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/android.hardware.boot@1.2.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libboot_control_client.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libboot_control_client.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libbootloader_message.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libbootloader_message.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libboot_control_client_unisoc.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libboot_control_client_unisoc.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libproduction_client_unisoc.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libproduction_client_unisoc.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/vendor.sprd.hardware.boot-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/vendor.sprd.hardware.boot-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/vendor.sprd.hardware.boot@1.2.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/vendor.sprd.hardware.boot@1.2.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/vendor.sprd.hardware.production-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/vendor.sprd.hardware.production-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/hw/android.hardware.boot@1.0-impl-1.2.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/hw/android.hardware.boot@1.0-impl-1.2.so

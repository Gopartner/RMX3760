#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/realme/RMX3760

# Enable Virtual A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Dynamic Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# A/B Post-Install Configuration
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true

# Paket Utilitas, Fastbootd & Dependensi NDK/C++ Runtime
PRODUCT_PACKAGES += \
    fastbootd \
    resetprop \
    setprop \
    libbinder_ndk \
    libc++ \
    libutils \
    libcutils \
    libhardware \
    libbase

# Paket A/B Update Engine & Post-install Script
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

# Boot Control HAL (Khas Unisoc T612 / ums9230 AIDL)
PRODUCT_PACKAGES += \
    android.hardware.boot-service.default_recovery

# 1. Salin Root Script, Manifest VINTF (.xml), Init Scripts (.rc), dan Partition Table (fstab)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/init.recovery.common.rc:recovery/root/init.recovery.common.rc \
    $(LOCAL_PATH)/recovery/root/servicemanager.recovery.rc:recovery/root/servicemanager.recovery.rc \
    $(LOCAL_PATH)/recovery/root/android.hardware.boot-service.default_recovery.rc:recovery/root/system/etc/init/android.hardware.boot-service.default_recovery.rc \
    $(LOCAL_PATH)/recovery/root/system/etc/init/android.hardware.boot-service.default_recovery.rc:recovery/root/system/etc/init/android.hardware.boot-service.default_recovery.rc \
    $(LOCAL_PATH)/recovery/root/system/etc/init/vendor.sprd.hardware.boot-service.default_recovery.rc:recovery/root/system/etc/init/vendor.sprd.hardware.boot-service.default_recovery.rc \
    $(LOCAL_PATH)/recovery/root/system/etc/recovery.fstab:recovery/root/system/etc/recovery.fstab \
    $(LOCAL_PATH)/recovery/root/system/etc/vintf/manifest/vendor.sprd.hardware.boot-service.default.xml:recovery/root/system/etc/vintf/manifest/vendor.sprd.hardware.boot-service.default.xml

# 2. Salin Kedua Binary Executable Asli dari system/bin/hw/ (Presisi 1:1 Tanpa Pengubahan Nama)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/bin/hw/android.hardware.boot-service.default_recovery:recovery/root/system/bin/hw/android.hardware.boot-service.default_recovery \
    $(LOCAL_PATH)/recovery/root/system/bin/hw/vendor.sprd.hardware.boot-service.default_recovery:recovery/root/system/bin/hw/vendor.sprd.hardware.boot-service.default_recovery

# 3. Salin Seluruh Shared Library (.so) Asli dari system/lib64/ dan system/lib64/hw/
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/lib64/android.hardware.boot-V1-ndk.so:recovery/root/system/lib64/android.hardware.boot-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/vendor.sprd.hardware.boot-V1-ndk.so:recovery/root/system/lib64/vendor.sprd.hardware.boot-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/vendor.sprd.hardware.production-V1-ndk.so:recovery/root/system/lib64/vendor.sprd.hardware.production-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libboot_control_client_unisoc.so:recovery/root/system/lib64/libboot_control_client_unisoc.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libproduction_client_unisoc.so:recovery/root/system/lib64/libproduction_client_unisoc.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/hw/android.hardware.boot@1.0-impl-1.2.so:recovery/root/system/lib64/hw/android.hardware.boot@1.0-impl-1.2.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/hw/bootctrl.default.so:recovery/root/system/lib64/hw/bootctrl.default.so

# 4. Salin Konfigurasi ueventd Hardware Unisoc T612 yang Ada di Tree
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_hulk.rc:recovery/root/ueventd.ums9230_hulk.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_hulkU.rc:recovery/root/ueventd.ums9230_hulkU.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_1h10.rc:recovery/root/ueventd.ums9230_1h10.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_6h10.rc:recovery/root/ueventd.ums9230_6h10.rc

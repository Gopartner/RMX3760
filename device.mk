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

# Paket Utilitas
PRODUCT_PACKAGES += \
    fastbootd \
    resetprop \
    setprop

# Paket A/B Update Engine & Post-install Script
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

# 1. Init scripts, VINTF & recovery.fstab
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/init.recovery.common.rc:recovery/root/init.recovery.common.rc \
    $(LOCAL_PATH)/recovery/root/system/etc/init/servicemanager.recovery.rc:recovery/root/system/etc/init/servicemanager.recovery.rc \
    $(LOCAL_PATH)/recovery/root/system/etc/init/vendor.sprd.hardware.boot-service.default_recovery.rc:recovery/root/system/etc/init/vendor.sprd.hardware.boot-service.default_recovery.rc \
    $(LOCAL_PATH)/recovery/root/system/etc/recovery.fstab:recovery/root/system/etc/recovery.fstab \
    $(LOCAL_PATH)/recovery/root/system/etc/vintf/manifest/vendor.sprd.hardware.boot-service.default.xml:recovery/root/system/etc/vintf/manifest/vendor.sprd.hardware.boot-service.default.xml

# 2. Vendor Boot HAL Binary
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/bin/hw/vendor.sprd.hardware.boot-service.default_recovery:recovery/root/system/bin/hw/vendor.sprd.hardware.boot-service.default_recovery

# 3. Vendor Boot HAL Libraries
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/lib64/android.hardware.boot-V1-ndk.so:recovery/root/system/lib64/android.hardware.boot-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/vendor.sprd.hardware.boot-V1-ndk.so:recovery/root/system/lib64/vendor.sprd.hardware.boot-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/vendor.sprd.hardware.production-V1-ndk.so:recovery/root/system/lib64/vendor.sprd.hardware.production-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libboot_control_client_unisoc.so:recovery/root/system/lib64/libboot_control_client_unisoc.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libproduction_client_unisoc.so:recovery/root/system/lib64/libproduction_client_unisoc.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/hw/android.hardware.boot@1.0-impl-1.2.so:recovery/root/system/lib64/hw/android.hardware.boot@1.0-impl-1.2.so

# 4. ueventd
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/ueventd.uis7863_6h10.rc:recovery/root/ueventd.uis7863_6h10.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.uis7863_6h10_go.rc:recovery/root/ueventd.uis7863_6h10_go.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.uis7865_6h10.rc:recovery/root/ueventd.uis7865_6h10.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.uis7865_6h10_go.rc:recovery/root/ueventd.uis7865_6h10_go.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_14c10_go.rc:recovery/root/ueventd.ums9230_14c10_go.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_1h10.rc:recovery/root/ueventd.ums9230_1h10.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_1h10_go.rc:recovery/root/ueventd.ums9230_1h10_go.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_4h10.rc:recovery/root/ueventd.ums9230_4h10.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_4h10_go.rc:recovery/root/ueventd.ums9230_4h10_go.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_6h10.rc:recovery/root/ueventd.ums9230_6h10.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_6h10_go.rc:recovery/root/ueventd.ums9230_6h10_go.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_dhaka.rc:recovery/root/ueventd.ums9230_dhaka.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_dhaka_go.rc:recovery/root/ueventd.ums9230_dhaka_go.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_hulk.rc:recovery/root/ueventd.ums9230_hulk.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_hulkU.rc:recovery/root/ueventd.ums9230_hulkU.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.ums9230_latte.rc:recovery/root/ueventd.ums9230_latte.rc

# 5. first_stage_ramdisk
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/recovery/root/first_stage_ramdisk,recovery/root/first_stage_ramdisk)

# 6. modules metadata
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/lib/modules/modules.dep:recovery/root/lib/modules/modules.dep \
    $(LOCAL_PATH)/recovery/root/lib/modules/modules.load:recovery/root/lib/modules/modules.load \
    $(LOCAL_PATH)/recovery/root/lib/modules/modules.load.recovery:recovery/root/lib/modules/modules.load.recovery \
    $(LOCAL_PATH)/recovery/root/lib/modules/modules.alias:recovery/root/lib/modules/modules.alias \
    $(LOCAL_PATH)/recovery/root/lib/modules/modules.softdep:recovery/root/lib/modules/modules.softdep

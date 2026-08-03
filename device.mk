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

# Paket Utilitas & Fastbootd
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

# Boot Control HAL (Khas Unisoc T612 / ums9230)
PRODUCT_PACKAGES += \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service \
    android.hardware.boot-service.default_recovery

# Copy File Recovery Root (Init scripts & Boot control Unisoc dari folder recovery/root)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/init.recovery.common.rc:recovery/root/init.recovery.common.rc \
    $(LOCAL_PATH)/recovery/root/servicemanager.recovery.rc:recovery/root/servicemanager.recovery.rc \
    $(LOCAL_PATH)/recovery/root/vendor.sprd.hardware.boot-service.default_recovery.rc:recovery/root/vendor.sprd.hardware.boot-service.default_recovery.rc

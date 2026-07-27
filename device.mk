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

# Virtual A/B OTA
ENABLE_VIRTUAL_AB := true

# A/B Partitions Configuration (Pola Nino088 + Partisi RMX3760)
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    sdc \
    trustos \
    sml \
    teecfg \
    vbmeta \
    vbmeta_system \
    vbmeta_system_ext \
    vbmeta_vendor \
    vbmeta_product \
    dtbo \
    uboot \
    vendor_boot \
    init_boot \
    l_modem \
    l_gdsp \
    l_ldsp \
    l_agdsp \
    pm_sys \
    l_fixnv1 \
    l_fixnv2 \
    l_deltanv \
    system_dlkm \
    vendor_dlkm \
    system \
    system_ext \
    vendor \
    product \
    odm

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

# Boot Control HAL 1.2 (Pola Nino088 untuk Unisoc UMS9230)
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl-recovery \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-service

PRODUCT_PACKAGES += \
    bootctrl.ums9230 \
    bootctrl.ums9230.recovery

PRODUCT_PACKAGES_DEBUG += \
    bootctrl \
    update_engine_client

# Health HAL
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# Fastbootd Stuff
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    android.hardware.fastboot@1.0-impl-mock.recovery \
    fastbootd

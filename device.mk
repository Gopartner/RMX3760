#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 OrangeFox Recovery Project
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

# Boot Control HAL 1.2 & Fastbootd (Dikompilasi Native oleh Source Code OrangeFox)
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-service \
    fastbootd

# Health HAL
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# VINTF Manifests & Scripts Vendor Unisoc (File Asli)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/etc/vintf/manifest/vendor.sprd.hardware.boot-service.default.xml:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/vintf/manifest/vendor.sprd.hardware.boot-service.default.xml \
    $(LOCAL_PATH)/recovery/root/system/bin/create_splloader_dual_slot_byname_path.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/create_splloader_dual_slot_byname_path.sh \
    $(LOCAL_PATH)/recovery/root/system/etc/init/vendor.sprd.hardware.boot-service.default_recovery.rc:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/init/vendor.sprd.hardware.boot-service.default_recovery.rc \
    $(LOCAL_PATH)/recovery/root/system/etc/init/servicemanager.recovery.rc:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/init/servicemanager.recovery.rc

# Bootconfig Injection
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/bootconfig:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/bootconfig \
    $(LOCAL_PATH)/bootconfig:$(TARGET_COPY_OUT_RECOVERY)/root/bootconfig

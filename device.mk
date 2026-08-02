#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/realme/RMX3760
# A/B
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true

# Boot control HAL
PRODUCT_PACKAGES += \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service

PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

# BOOT CONTROL
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/lib64/hw/bootctrl.default.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/hw/bootctrl.default.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/hw/android.hardware.boot@1.0-impl-1.2.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/hw/android.hardware.boot@1.0-impl-1.2.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/android.hardware.boot-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/android.hardware.boot-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/vendor.sprd.hardware.boot-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/vendor.sprd.hardware.boot-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/vendor.sprd.hardware.production-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/vendor.sprd.hardware.production-V1-ndk.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libboot_control_client_unisoc.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libboot_control_client_unisoc.so \
    $(LOCAL_PATH)/recovery/root/system/lib64/libproduction_client_unisoc.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libproduction_client_unisoc.so

#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 OrangeFox Recovery Project
#

# Inherit from core products
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)

# Inherit device configuration
$(call inherit-product, device/realme/RMX3760/device.mk)

# Inherit OrangeFox Vendor Config (Sinkron dengan OrangeFox Branch 12.1)
$(call inherit-product, vendor/recovery/orangefox/vendor.mk)

# Product Identifiers RMX3760
PRODUCT_DEVICE := RMX3760
PRODUCT_NAME := twrp_RMX3760
PRODUCT_BRAND := realme
PRODUCT_MODEL := RMX3760
PRODUCT_MANUFACTURER := realme

PRODUCT_GMS_CLIENTID_BASE := android-oppo

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="ums9230_hulk_Natv-user 15 AP3A.240905.015.A2 40 release-keys" \
    TARGET_DEVICE="RMX3760" \
    PRODUCT_NAME="RMX3760" \
    PRODUCT_MODEL="RMX3760" \
    PRODUCT_DEVICE="RE58C2"

BUILD_FINGERPRINT := realme/RMX3760/RE58C2:15/AP3A.240905.015.A2/T.R4T2.1777915050:user/release-keys

#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Omni stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from RMX3760 device
$(call inherit-product, device/realme/RMX3760/device.mk)

PRODUCT_DEVICE := RMX3760
PRODUCT_NAME := twrp_RMX3760
PRODUCT_BRAND := realme
PRODUCT_MODEL := Realme C53
PRODUCT_MANUFACTURER := realme

PRODUCT_GMS_CLIENTID_BASE := android-oppo

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="RMX3760_full-user 15 AP3A.240905.015.A2 40 release-keys"

BUILD_FINGERPRINT := realme/RMX3760/RE58C2:15/AP3A.240905.015.A2/T.R4T2.1777915050:user/release-keys

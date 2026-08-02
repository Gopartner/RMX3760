# Vendorsetup script for Realme C53 (RMX3760)

# Add lunch combo
add_lunch_combo twrp_RMX3760-eng
add_lunch_combo twrp_RMX3760-userdebug

# Bypass missing dependencies error in AOSP Minimal Tree
export ALLOW_MISSING_DEPENDENCIES=true
export FOX_BUILD_TYPE="Unofficial"
export LC_ALL="C"

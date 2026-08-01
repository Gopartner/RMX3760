#!/system/bin/sh

LOGDIR=/data/media/0/TWRP-BOOTLOG
mkdir -p "$LOGDIR"

LOG="$LOGDIR/boot.log"

{
echo
echo "==============================="
date

echo
echo "==== ro.boot ===="
getprop | grep '^\\[ro.boot'

echo
echo "==== boot ===="
getprop | grep boot

echo
echo "==== mount ===="
mount

echo
echo "==== dmesg ===="
dmesg

echo
echo "==== logcat ===="
logcat -d

} >> "$LOG" 2>&1

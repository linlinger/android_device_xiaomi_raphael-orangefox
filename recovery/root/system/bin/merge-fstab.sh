#!/system/bin/sh

# Check FBE encryption status
FBE=$(getprop ro.crypto.dm_default_key.options_format.version)

# Dynamic Partitions
if dd if=/dev/block/by-name/system bs=256k count=1|strings|grep -q -E 'raphael_dynamic_partitions|qti_dynamic_partitions' > /dev/null; then
    echo >> /system/etc/recovery.fstab
    for p in system system_ext product vendor odm; do
        echo "${p} /${p} ext4 ro,barrier=1,discard wait,logical" >> /system/etc/recovery.fstab
        echo "${p} /${p} erofs ro wait,logical" >> /system/etc/recovery.fstab
    done
    echo >> /system/etc/twrp.flags
    for p in vendor; do
        echo "/super_${p} emmc /dev/block/by-name/${p} flags=display=\"Super_${p}\";backup=1" >> /system/etc/twrp.flags
    done
    # Time to check fbe encryption status
    if [ "$FBE" = "2" ]; then
        cat /system/etc/recovery.fstab.fbev2 >> /system/etc/recovery.fstab
    else
        cat /system/etc/recovery.fstab.fbev1 >> /system/etc/recovery.fstab
    fi
else
# Non dynamic partition
    # Fix MTG Installation
    ln -s /dev/block/bootdevice/by-name /dev/block/mapper
    echo >> /system/etc/twrp.flags
    cat /system/etc/twrp.flags.nondynpart >> /system/etc/twrp.flags
    echo "/super emmc /dev/block/by-name/system flags=display=\"Super\"" >> /system/etc/twrp.flags
    if [ "$FBE" = "2" ]; then
        cat /system/etc/recovery.fstab.fbev2 >> /system/etc/recovery.fstab
    else
        cat /system/etc/recovery.fstab.fbev1 >> /system/etc/recovery.fstab
    fi
fi

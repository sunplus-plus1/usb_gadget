#!/bin/sh

SOC_PLATFORM_PATH=/sys/devices/platform

switch_udc() {
    if [ -d "${SOC_PLATFORM_PATH}/soc@B" ]; then
        echo d > ${SOC_PLATFORM_PATH}/soc@B/9c102800.usb/udc_ctrl
    elif [ -d "${SOC_PLATFORM_PATH}/soc-B" ]; then
        if [ -f "${SOC_PLATFORM_PATH}/soc-B/9c102800.usb/udc_ctrl" ]; then
            echo d > ${SOC_PLATFORM_PATH}/soc-B/9c102800.usb/udc_ctrl
        else 
            echo d > ${SOC_PLATFORM_PATH}/soc-B/9c102800.usb/udc_ctrl$1
        fi
    fi
}

KERNEL_PATH=/lib/modules/`uname -r`/kernel
GADGET_PATH=$KERNEL_PATH/drivers/usb/gadget
COMPOSITE=$GADGET_PATH/libcomposite.ko
USB_F_MASS_STORAGE=$GADGET_PATH/function/usb_f_mass_storage.ko
CONFIGFS=$KERNEL_PATH/fs/configfs/configfs.ko

MEDIUM=$1

insmod $CONFIGFS
insmod $COMPOSITE
insmod $USB_F_MASS_STORAGE

#disable debug message
echo 0 > /sys/module/sunplus_udc/parameters/dmsg

mount -t configfs none /sys/kernel/config
cd /sys/kernel/config/usb_gadget

mkdir g1
cd g1

echo 64 > bMaxPacketSize0
echo 0x200 > bcdUSB
echo 0x100 > bcdDevice

# VID: NetChip
echo 0x0525 > idVendor

# PID: Linux-USB File-backed Storage Gadget 
echo 0xa4a5 > idProduct

mkdir functions/mass_storage.ms0
mkdir configs/c1.1

LUN0_PATH=configs/c1.1/mass_storage.ms0/lun.0
ln -s functions/mass_storage.ms0 configs/c1.1/

# setting medium 
echo "$MEDIUM" > ${LUN0_PATH}/file
echo 1 > ${LUN0_PATH}/removable
echo 0 > ${LUN0_PATH}/ro

# bind udc
echo "9c102800.usb" > UDC

# switch udc to device
switch_udc 0

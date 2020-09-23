#!/bin/sh

KERNEL_PATH=/lib/modules/`uname -r`/kernel
GADGET_PATH=$KERNEL_PATH/drivers/usb/gadget
COMPOSITE=$GADGET_PATH/libcomposite.ko
USB_F_MASS_STORAGE=$GADGET_PATH/function/usb_f_mass_storage.ko
G_MASS_STORAGE=$GADGET_PATH/legacy/g_mass_storage.ko
CONFIGFS=$KERNEL_PATH/fs/configfs/configfs.ko
MEDIUM=$1

insmod $CONFIGFS
insmod $COMPOSITE
insmod $USB_F_MASS_STORAGE
insmod $G_MASS_STORAGE file=$MEDIUM removable=1 ro=0

#disable debug message
echo 0 > /sys/module/sunplus_udc/parameters/dmsg

mount -t configfs none /sys/kernel/config
cd /sys/kernel/config/usb_gadget
mkdir g1
cd g1
echo "64" > bMaxPacketSize0
echo "0x200" > bcdUSB
echo "0x100" > bcdDevice
echo "0x03FD" > idVendor
echo "0x0500" > idProduct
mkdir functions/mass_storage.ms0
mkdir configs/c1.1

ln -s functions/mass_storage.ms0 configs/c1.1/
echo "9c102800.usb" > UDC
echo d > /sys/devices/platform/soc@B/9c102800.usb/udc_ctrl

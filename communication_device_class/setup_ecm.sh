#!/bin/sh

KERNEL_PATH=/lib/modules/`uname -r`/kernel
GADGET_PATH=$KERNEL_PATH/drivers/usb/gadget
FUNCTION_PATH=$GADGET_PATH/function
LEGACY_PATH=$GADGET_PATH/legacy
CONFIGFS=$KERNEL_PATH/fs/configfs/configfs.ko
COMPOSITE=$GADGET_PATH/libcomposite.ko
U_ETHER=$FUNCTION_PATH/u_ether.ko
USB_F_RNDIS=$FUNCTION_PATH/usb_f_rndis.ko
USB_F_ECM=$FUNCTION_PATH/usb_f_ecm.ko
G_ETHER=$LEGACY_PATH/g_ether.ko

HOST_MAC=22:aa:8b:ef:7d:c0
DEV_MAC=e6:76:ec:05:28:f3
DEV_IP=192.168.10.20

insmod $CONFIGFS
insmod $COMPOSITE
insmod $U_ETHER
insmod $USB_F_RNDIS
insmod $USB_F_ECM

#insmod usb_f_ecm_subset.ko
insmod $G_ETHER host_addr="$HOST_MAC" dev_addr="$DEV_MAC"

#disable debug message
echo 0 > /sys/module/sunplus_udc/parameters/dmsg

mkdir -p /sys/kernel/config 
mount -t configfs none /sys/kernel/config  
cd /sys/kernel/config/usb_gadget

mkdir g_ecm
mkdir g1  
cd g1

echo "512" > bMaxPacketSize0  
echo "0x200" > bcdUSB
echo "0x100" > bcdDevice
echo "0x03fd" > idVendor
echo "0x0104" > idProduct

mkdir configs/c1.1  
mkdir configs/c1.1/strings/0x409
echo "PLUS1" > configs/c1.1/strings/0x409/configuration

mkdir strings/0x409
echo "20200506141600-001" > strings/0x409/serialnumber
echo "Sunplus" > strings/0x409/manufacturer
echo "SP7021" > strings/0x409/product

#mkdir -p functions/ecm.usb0
# first byte of address must be even
#echo "22:aa:8b:ef:7d:c0" > functions/ecm.usb0/host_addr
#echo "e6:76:ec:05:28:f3" > functions/ecm.usb0/dev_addr

mkdir functions/ecm.0
ln -s functions/ecm.0 configs/c1.1

#mkdir functions/rndis.rn0 
#ln -s functions/rndis.rn0/ configs/c1.1/
 
echo "9c102800.usb" > UDC
echo d > /sys/devices/platform/soc@B/9c102800.usb/udc_ctrl

#set ip
ifconfig usb0 $DEV_IP netmask 255.255.255.0 up
#arp -s 192.168.10.30 22:aa:8b:ef:7d:c0


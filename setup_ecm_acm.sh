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
FUNCTION_PATH=$GADGET_PATH/function
LEGACY_PATH=$GADGET_PATH/legacy
# CONFIGFS=$KERNEL_PATH/fs/configfs/configfs.ko
COMPOSITE=$GADGET_PATH/libcomposite.ko
U_ETHER=$FUNCTION_PATH/u_ether.ko
USB_F_RNDIS=$FUNCTION_PATH/usb_f_rndis.ko
USB_F_ECM=$FUNCTION_PATH/usb_f_ecm.ko
USB_F_SERIAL=$FUNCTION_PATH/usb_f_serial.ko
USB_F_ACM=$FUNCTION_PATH/usb_f_acm.ko
USB_F_OBX=$FUNCTION_PATH/usb_f_obex.ko
USB_U_SERIAL=$FUNCTION_PATH/u_serial.ko

HOST_MAC=22:aa:8b:ef:7d:c0
DEV_MAC=e6:76:ec:05:28:f3
DEV_IP=192.168.10.20

# insmod $CONFIGFS
insmod $USB_U_SERIAL
insmod $COMPOSITE
insmod $USB_F_SERIAL
insmod $USB_F_OBX
insmod $USB_F_ACM
insmod $U_ETHER
insmod $USB_F_RNDIS
insmod $USB_F_ECM

# insmod $G_ETHER host_addr="$HOST_MAC" dev_addr="$DEV_MAC"

# disable debug message
echo 0 > /sys/module/sunplus_udc/parameters/dmsg

mkdir -p /sys/kernel/config 
# mount -t configfs none /sys/kernel/config  
cd /sys/kernel/config/usb_gadget

# create gadget 1/2 folder

mkdir g1  
mkdir g2

# setup gadget 1

cd g1

echo 64 > bMaxPacketSize0  
echo 0x200 > bcdUSB
echo 0x100 > bcdDevice

### VID: NetChip 
echo 0x0525	> idVendor    

### PID: Linux-USB Ethernet Gadget  
echo 0xa4a1 > idProduct

echo 1 > bDeviceProtocol

mkdir -p configs/c1.1
mkdir -p configs/c1.1/strings/0x409
echo "ethe" > configs/c1.1/strings/0x409/configuration

mkdir strings/0x409
echo "" > strings/0x409/serialnumber
echo "Sunplus" > strings/0x409/manufacturer
echo "SP7021" > strings/0x409/product

mkdir functions/ecm.usb0
echo "22:aa:8b:ef:7d:c0" > functions/ecm.usb0/host_addr
echo "e6:76:ec:05:28:f3" > functions/ecm.usb0/dev_addr
ln -s functions/ecm.usb0 configs/c1.1

mkdir functions/rndis.rn0 
ln -s functions/rndis.rn0/ configs/c1.1/

# bind UDC
echo "9c102800.usb" > UDC

# switch UDC0 to device
switch_udc 0

# setup gadget 2

cd -
cd g2

echo 64 > bMaxPacketSize0  
echo 0x200 > bcdUSB
echo 0x100 > bcdDevice

### VID: NetChip
echo 0x0525	> idVendor    

### PID: Linux-USB Serial Gadget as CDC-ACM   
echo 0xa4a7 > idProduct

echo 1 > bDeviceProtocol

mkdir -p configs/c1.1
mkdir -p configs/c1.1/strings/0x409
echo "serial" > configs/c1.1/strings/0x409/configuration

mkdir strings/0x409
echo "" > strings/0x409/serialnumber
echo "Sunplus" > strings/0x409/manufacturer
echo "SP7021" > strings/0x409/product

mkdir functions/acm.GS0
ln -s functions/acm.GS0 configs/c1.1

# bind UDC
echo "9c103800.usb" > UDC

# switch UDC1 to device
switch_udc 1

# set ip
ifconfig lo up
ifconfig usb0 ${DEV_IP} netmask 255.255.255.0 up
#arp -s 193.168.10.30 22:aa:8b:ef:7d:c0



# How to enable USB gadget
1. If source code isn't compiled with gadget configs, please refer to [How to compile](https://github.com/sunplus-plus1/SP7021)

>Enable Mass Storage gadget (Ubuntu and Windows is supported)
2. boot your develop board and connect micro usb to PC
3. copy mass_storage_class/setup_mass.sh to develop board
4. If you want to use device as medium \
insert sdcard to develop board and it will be /dev/mmcblk1
    ```
    ./setup_mass.sh /dev/mmcblk1
    ```
5. If you want to use file as medium: \
run below command to create vfat image file in your PC
    ```
    dd if=/dev/zero of=fdev count=100 bs=1M
    mkfs.vfat fdev
    ```
    copy fdev file to same folder with setup_mass.sh of develop board and run ...
    ```
    ./setup_mass.sh fdev
    ```
    \
![](https://github.com/sunplus-plus1/usb_gadget/blob/master/mass_storage_class/pic/storage_copy.png)
6. Result\
\
![](https://github.com/sunplus-plus1/usb_gadget/blob/master/mass_storage_class/pic/storage_result.png)

>Enable communication device class gadget
2. boot your develop board and connect micro usb to PC
3. copy communication_device_class/setup_ecm.sh to develop board
4. setup Host (untuntu 14, Windows doesn't yet support) network connections\
2.1 run 'nm-connection-editor' and Press "Add" in network connections\
\
![](https://github.com/sunplus-plus1/usb_gadget/blob/master/communication_device_class/pic/network_setting_main.png)\
\
2.2 Choose Enternet\
\
![](https://github.com/sunplus-plus1/usb_gadget/blob/master/communication_device_class/pic/network_setting_choose.png)\
\
2.3 Set connection name and MAC address\
\
![](https://github.com/sunplus-plus1/usb_gadget/blob/master/communication_device_class/pic/network_setting_mac.png)\
\
2.4 Set IP\
\
![](https://github.com/sunplus-plus1/usb_gadget/blob/master/communication_device_class/pic/network_setting_ip.png)\
\
2.4 New network connection (usb0) will create\
\
![](https://github.com/sunplus-plus1/usb_gadget/blob/master/communication_device_class/pic/network_setting_ok.png)


5. run setup_ecm.sh
6. Result\
\
![](https://github.com/sunplus-plus1/usb_gadget/blob/master/communication_device_class/pic/network_setting_work.png)

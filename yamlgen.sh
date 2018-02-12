#!/bin/bash
tar -xf $1
cd $(ls $1 | cut -d . -f 1,2)
#Device info
device_name=$(cat system/build.prop | grep ro.product.model= | cut -d = -f 2)
device_codename=$(cat system/build.prop | grep ro.product.device= | cut -d = -f 2)
device_brand=$(cat system/build.prop | grep ro.product.brand= | cut -d = -f 2)
device_id=$(cat system/build.prop | grep ro.build.fingerprint= | cut -d / -f 2 | cut -d _ -f 2)
device_architecture=$(cat system/build.prop | grep ro.product.cpu.abi= | cut -d = -f 2)
#Partitions info
partition_path_1=/$(cat recovery/recovery.fstab | grep by-name | cut -d : -f1 | head -n1 | cut -d / -f 3,4,5,6)
if [ "$partition_path_1" != "/dev/block/bootdevice/by-name" ] ; then
	partition_path_1=none
else
	partition_path_1=$partition_path_1
fi

system=$(cat recovery/recovery.fstab | grep -i -w system | cut  -d\   -f1 | cut -d / -f2 | tail -n1 | sed 's/\s.*$//')
if [ "$system" != "" ] ; then
	system=$system
	cache=$(cat recovery/recovery.fstab | grep -i cache | cut  -d\   -f1 | cut -d / -f2 | tail -n1 | sed 's/\s.*$//')
	data=$(cat recovery/recovery.fstab | grep -i data | cut  -d\   -f1 | cut -d / -f2 | head -n1 | sed 's/\s.*$//')
	boot=$(cat recovery/recovery.fstab | grep -i -w boot | cut  -d\   -f1 | cut -d / -f2 | tail -n1 | sed 's/\s.*$//')
	recovery=$(cat recovery/recovery.fstab | grep -i recovery | cut  -d\   -f1 | cut -d / -f2 | tail -n1 | sed 's/\s.*$//')
else
	system=$(cat listings/dev_full | grep " -> /dev/block/" | grep -i system | cut -d\   -f27 | tail -n1 | sed 's/\s.*$//')
	cache=$(cat listings/dev_full | grep " -> /dev/block/" | grep -i cache | cut -d\   -f27 | tail -n1 | sed 's/\s.*$//')
	data=$(cat listings/dev_full | grep " -> /dev/block/" | grep -i data | cut -d\   -f27 | tail -n1 | sed 's/\s.*$//')
	boot=$(cat listings/dev_full | grep " -> /dev/block/" | grep -i -w boot | cut -d\   -f27 | tail -n1 | sed 's/\s.*$//')
	recovery=$(cat listings/dev_full | grep " -> /dev/block/" | grep -i recovery | cut -d\   -f27 | tail -n1 | sed 's/\s.*$//')
fi
#Path 1
if [ "$partition_path_1" != none ] ; then
	system_p1=$partition_path_1/$system
	cache_p1=$partition_path_1/$cache
	data_p1=$partition_path_1/$data
	boot_p1=$partition_path_1/$boot
	recovery_p1=$partition_path_1/$recovery
else
	system_p1=none
	cache_p1=none
	data_p1=none
	boot_p1=none
	recovery_p1=none
fi
#Path 2
partition_path_2=$(cat listings/dev_full | grep by-name | tail -n1 | cut -d : -f1)
if [ $? = 0 ] ; then
	system_p2=$partition_path_2/$system
	cache_p2=$partition_path_2/$cache
	data_p2=$partition_path_2/$data
	boot_p2=$partition_path_2/$boot
	recovery_p2=$partition_path_2/$recovery
else
	system_p2=none
	cache_p2=none
	data_p2=none
	boot_p2=none
	recovery_p2=none
fi
#Path 3
system_p3=$(cat recovery/recovery.log | grep "/system | /dev/block" | cut -d '|' -f 2 | sed 's/ //g')
cache_p3=$(cat recovery/recovery.log | grep "/cache | /dev/block" | cut -d '|' -f 2 | sed 's/ //g')
data_p3=$(cat recovery/recovery.log | grep "/data | /dev/block" | cut -d '|' -f 2 | sed 's/ //g')
boot_p3=$(cat recovery/recovery.log | grep "/boot | /dev/block" | cut -d '|' -f 2 | sed 's/ //g')
recovery_p3=$(cat recovery/recovery.log | grep "/recovery | /dev/block" | cut -d '|' -f 2 | sed 's/ //g')
#Bootui info
pixel=$(cat recovery/recovery.log | grep GGL_PIXEL_FORMAT_ | cut -d _ -f 4,5 | tail -n1 | sed 's/ //g')
brightness=$(cat recovery/recovery.log | grep TW_BRIGHTNESS_PATH | cut -d = -f 2 | sed 's/ //g')
brightness_control=$(cat recovery/recovery.log | grep 'Setting brightness control to' | grep -o '[0-9]*' | head -n1)
#Flags
flag_1=$(cat recovery/recovery.log | grep 'TW_GRAPHICS_FORCE_USE_LINELENGTH')
if [ $? = 0 ] ; then
	flag_1=TW_GRAPHICS_FORCE_USE_LINELENGTH
else
	flag_1=none
fi
flag_2=$(cat recovery/recovery.log | grep 'TW_QCOM_RTC_FIX')
if [ $? = 0 ] ; then
	flag_2=TW_QCOM_RTC_FIX
else
	flag_2=none
fi
flag_3=$(cat recovery/recovery.log | grep 'TW_HAS_DOWNLOAD_MODE')
if [ $? = 0 ] ; then
	flag_3=TW_HAS_DOWNLOAD_MODE
else
	flag_3=none
fi
flag_4=$(cat recovery/recovery.log | grep 'TW_PREFER_LCD_BACKLIGHT')
if [ $? = 0 ] ; then
	flag_4=TW_PREFER_LCD_BACKLIGHT
else
	flag_4=none
fi
flag_5=$(cat recovery/recovery.log | grep 'TW_NO_SCREEN_TIMEOUT')
if [ $? = 0 ] ; then
	flag_5=TW_NO_SCREEN_TIMEOUT
else
	flag_5=none
fi
flag_6=$(cat recovery/recovery.log | grep 'TW_NO_CPU_TEMP')
if [ $? = 0 ] ; then
	flag_6=TW_NO_CPU_TEMP
else
	flag_6=none
fi
flag_7=$(cat recovery/recovery.log | grep 'TW_SCREEN_BLANK_ON_BOOT')
if [ $? = 0 ] ; then
	flag_7=TW_SCREEN_BLANK_ON_BOOT
else
	flag_7=none
fi
#Generate
mkyaml(){
cat << EOF

- name: $device_name
  id: $device_id
  codenames:
    - $device_codename
    - $device_id
  architecture: $device_architecture

  block_devs:
    base_dirs:
      - $partition_path_1
      - $partition_path_2
    system:
      - $system_p1
      - $system_p2
      - $system_p3
    cache:
      - $cache_p1
      - $cache_p2
      - $cache_p3
    data:
      - $data_p1
      - $data_p2
      - $data_p3
    boot:
      - $boot_p1
      - $boot_p2
      - $boot_p3
    recovery:
      - $recovery_p1
      - $recovery_p2
      - $recovery_p3

  boot_ui:
    supported: true
    flags:
      - $flag_1
      - $flag_2
      - $flag_3
      - $flag_4
      - $flag_5
      - $flag_6
      - $flag_7
    graphics_backends:
      - fbdev
    pixel_format: $pixel
    brightness_path: $brightness
    default_brightness: $brightness_control
    theme: portrait_hdpi
EOF
}

if [ -e ../$device_brand.yml ]
then
	mkyaml >> ../$device_brand.yml
else
    echo "---" > ../$device_brand.yml ; mkyaml >> ../$device_brand.yml
fi
sed -i '/none/d' ../$device_brand.yml
sed -i -- 's/system_image/system/g' ../$device_brand.yml

#Clean
cd ..
rm -rf $(ls $1 | cut -d . -f 1,2)
echo "Done! check your $device_brand.yml for any mistakes"

#!/bin/bash -e
 
port="/dev/ttyS2"
 
send_data () {
#        date_cksum=$(echo ${data} | cksum | awk '{print $1}')
        echo "\$${data}*${date_cksum}#"
#        echo -e "\$${data}*${date_cksum}#\n" > ${port}
}
 
if [ ! -f /sys/bus/iio/devices/iio:device0/in_temp_raw ] ; then
    echo si7005 0x40 > /sys/bus/i2c/devices/i2c-1/new_device
fi
 
in_temp_raw=$(cat /sys/bus/iio/devices/iio:device0/in_temp_raw || true)
in_temp_offset=$(cat /sys/bus/iio/devices/iio:device0/in_temp_offset || true)
in_temp_scale=$(cat /sys/bus/iio/devices/iio:device0/in_temp_scale || true)
  
if [ ! "x${in_temp_raw}" = "x" ] && [ ! "x${in_temp_offset}" = "x" ] && [ ! "x${in_temp_scale}" = "x" ] ; then
    temp=$(echo "${in_temp_raw} + ${in_temp_offset}" | bc)
    temp=$(echo "scale=5; ${temp} * ${in_temp_scale}" | bc)
    temp=$(echo "scale=5; ${temp} / 1000" | bc)
    data="TEXT,TEMP0,${temp},"
    send_data
fi

#!/bin/bash -e

. /home/debian/id.sh

send_data () {
	#echo "`date` temp: $temp: hum: $hum" | systemd-cat
	echo "`date` temp: $temp" | systemd-cat
	exo write ${cik} ${rid} --value=${temp}
	sleep 13
}

if [ ! -f /sys/bus/iio/devices/iio:device0/in_temp_raw ] ; then
	echo si7005 0x40 > /sys/bus/i2c/devices/i2c-1/new_device
	sleep 5
	exit 2
fi

get_data () {
	in_temp_raw=$(cat /sys/bus/iio/devices/iio:device0/in_temp_raw || true)
	in_temp_offset=$(cat /sys/bus/iio/devices/iio:device0/in_temp_offset || true)
	in_temp_scale=$(cat /sys/bus/iio/devices/iio:device0/in_temp_scale || true)

	if [ ! "x${in_temp_raw}" = "x" ] && [ ! "x${in_temp_offset}" = "x" ] && [ ! "x${in_temp_scale}" = "x" ] ; then
		temp=$(echo "${in_temp_raw} + ${in_temp_offset}" | bc)
		temp=$(echo "scale=5; ${temp} * ${in_temp_scale}" | bc)
		temp=$(echo "scale=3; ${temp} / 1000" | bc)

		#in_hum_raw=$(cat /sys/bus/iio/devices/iio:device0/in_humidityrelative_raw || true)
		#in_hum_offset=$(cat /sys/bus/iio/devices/iio:device0/in_humidityrelative_offset || true)
		#in_hum_scale=$(cat /sys/bus/iio/devices/iio:device0/in_humidityrelative_scale || true)

		#if [ ! "x${in_hum_raw}" = "x" ] && [ ! "x${in_hum_offset}" = "x" ] && [ ! "x${in_hum_scale}" = "x" ] ; then
		#	hum=$(echo "${in_hum_raw} + ${in_hum_offset}" | bc)
		#	hum=$(echo "scale=5; ${hum} * ${in_hum_scale}" | bc)
		#	hum=$(echo "scale=3; ${hum} / 1000" | bc)
			#echo ${hum}
			send_data
		#fi
	fi
}

if [ ! -f /tmp/lock.txt ] ; then
	touch /tmp/lock.txt

	while :
	do
		get_data
	#	sleep 1
	done
fi

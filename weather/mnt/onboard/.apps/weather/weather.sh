#!/bin/sh
if [ ! -f /mnt/onboard/.apps/koboWeather/location ];
then
    /mnt/onboard/.apps/koboWeather/set_location.sh
    echo "Just a moment . . ."
fi

#echo 1 > /sys/class/graphics/fb0/rotate
cd /mnt/onboard/.apps/koboWeather
python weather.py

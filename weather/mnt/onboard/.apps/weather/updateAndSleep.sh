#!/bin/sh

cd /mnt/onboard/.apps/koboWeather
#sh wifiup.sh 
battery=`cat /sys/devices/platform/pmic_battery.1/power_supply/mc13892_bat/capacity` 
python weather.py
sh wifidown.sh
sh sleep.sh

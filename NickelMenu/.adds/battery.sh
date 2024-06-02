# Battery Statistics Calculator 1.1 (2024-05-25) by Aleron Ives
# Modified by nodeg for the Kobo Libra Colour
#
# This script calculates battery statistics for the Kobo Libra Color.
# Check the contents of /sys/class/power_supply/ if you use a different
# model to ensure that the statistics you want to track are available.
#
# You can use NickelMenu to invoke this script like so:
# menu_item :main :Battery :cmd_output :500 :/mnt/onboard/.adds/battcalc.sh
#
# See
# https://www.mobileread.com/forums/showpost.php?p=4428032&postcount=1337

# Gather the necessary statistics
meter=$(cat /sys/class/power_supply/bd71827_bat/capacity)
v_now=$(cat /sys/class/power_supply/bd71827_bat/voltage_now)
v_min=$(cat /sys/class/power_supply/bd71827_bat/voltage_min)
v_max=$(cat /sys/class/power_supply/bd71827_bat/voltage_max)
c_now=$(cat /sys/class/power_supply/bd71827_bat/charge_now)
c_full=$(cat /sys/class/power_supply/bd71827_bat/charge_full)
c_dfull=$(cat /sys/class/power_supply/bd71827_bat/charge_full_design)

# Format the statistics
let v_pct=$v_max-$v_now; let v_pct/=9000 # Calculate charge percentage from V
let v_pct=100-$v_pct                     # "
let v_now/=1000; let v_min/=10000; let v_max/=10000  # Convert to V
let c_now/=1000; let c_full/=1000; let c_dfull/=1000 # Convert to mAh
let v_nowr=$v_now%1000; let v_now/=1000 # Simulate floating-point arithmetic
let v_minr=$v_min%100; let v_min/=100   # "
let v_maxr=$v_max%100; let v_max/=100   # "
let charge=$c_now*100/$c_full     # Calculate charge percentage from mAh
let c_health=$c_full*100/$c_dfull # Calculate health percentage from mAh

# Display the results
echo Capacity: $c_now mAh / $charge% / $meter%
echo Voltage: $v_min.$v_minr V / $v_now.$v_nowr V / $v_max.$v_maxr V / $v_pct%
echo Health: $c_full mAh / $c_dfull mAh / $c_health%

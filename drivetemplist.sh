#!/bin/bash
# Uses drivetemp kernel module to check drive temps and display their name
# https://unix.stackexchange.com/a/617450

drives=$(grep -l "drivetemp" /sys/class/hwmon/hwmon*/name)

while read -r f; 
    do printf "%s: %-.2s°C\n" "$(<"${f%/*}/device/model")" "$(<"${f%/*}/temp1_input")";
done <<< "${drives}"

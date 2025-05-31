#!/bin/bash
#IPMI script template

#Goal of script: Baseline script for fan automation so I don't hear fucking screaming all the goddam time from my R720

#TODO: Check Temps, if temps are at this range, set to RPM percent. Focus on CPU temps

#HEX FAN VALUES:
# 0% RPM | 0x00
# 5% RPM | 0x05
# 10% RPM | 0x0a
# 15% RPM | 0x0F
# 20% RPM | 0x14
# 25% RPM | 0x19
# 30% RPM | 0x1e
# 35% RPM | 0x23
# 40% RPM | 0x28 
# 45% RPM | 0x2D
# 50% RPM | 0x32
# 55% RPM | 0x37	
# 60% RPM | 0x3c
# 65% RPM | 0x41
# 70% RPM | 0x46
# 75% RPM | 0x4B
# 80% RPM | 0x50
# 85% RPM | 0x55
# 90% RPM | 0x5a
# 95% RPM | 0x5F
# 100% RPM | 0x64

#ESTABLISHING VARIABLES
#Make sure to change these values for script to run proper
username="test" 
password="test"
hostip="192.168.0.120"
ipmitoolFull="ipmitool -I lanplus -H $hostip -U $username -P $password"

#ENABLING AND DISABLING FANS
enableFanCtrl="raw 0x30 0x30 0x01 0x00"
disableFanCtrl="raw 0x30 0x30 0x01 0x01"
adjustFan="raw 0x30 0x30 0x02 0xff"

#Fan RPM variables 
fOff="raw 0x30 0x30 0x02 0xff 0x00"
f10="raw 0x30 0x30 0x02 0xff 0x0a"
f20="raw 0x30 0x30 0x02 0xff 0x14"
f30="raw 0x30 0x30 0x02 0xff 0x1e"
f35="raw 0x30 0x30 0x02 0xff 0x23"
f40="raw 0x30 0x30 0x02 0xff 0x28"
f45="raw 0x30 0x30 0x02 0xff 0x2D"
f50="raw 0x30 0x30 0x02 0xff 0x32"
f55="raw 0x30 0x30 0x02 0xff 0x37"
f60="raw 0x30 0x30 0x02 0xff 0x3c"
f65="raw 0x30 0x30 0x02 0xff 0x41"
f70="raw 0x30 0x30 0x02 0xff 0x46"
f75="raw 0x30 0x30 0x02 0xff 0x4B"
f80="raw 0x30 0x30 0x02 0xff 0x50"
f85="raw 0x30 0x30 0x02 0xff 0x55"
f90="raw 0x30 0x30 0x02 0xff 0x5a"
f95="raw 0x30 0x30 0x02 0xff 0x5F"
fmax="raw 0x30 0x30 0x02 0xff 0x64"

#Server Temps 
t40=40
t45=45
t50=50
t55=55
t60=60
t60=65
t70=70
t75=75
t80=80
t85=85
t90=90
t95=95
t100=100

#beginning of functions
#MAKE SURE TO REPLACE PATH!

ipmi_temp_data="[replace/path]ipmi_temperature_cache.txt" 

grab_ipmi_temp_data(){
	ipmitool -I lanplus -H $hostip -U $username -P $password sdr type Temperature > $ipmi_temp_data
	if [[ $? -ne 0 ]]; then
		return 1
	fi 
	return 0
}

get_cpu_temp() {
	local label=$1 
	grep -w "$label" "$ipmi_temp_data" | awk -F'|' '{print $5}' | awk 'NR==3' | sed 's/[^0-9.]//g'
}
#adding chassis power check
get_power_status() {
	ipmitool -I lanplus -H $hostip -U $username -P $password chassis status | grep "System"
	if [[ $($ipmi_power_check | grep 'on') ]]; then
		ipmitool -I lanplus -H $hostip -U $username -P $password raw 0x30 0x30 0x01 0x01
	else
		ipmitool -I lanplus -H $hostip -U $username -P $password raw 0x30 0x30 0x01 0x00
	fi
}

while true; do
	get_power_status
	grab_ipmi_temp_data
	temp=$(get_cpu_temp "$label")
	last_date_time=$(date)

	if (( temp <  t40 )); then
		$ipmitoolFull $f30
		echo "Current Fan Percentage: 30%"
	elif (( temp < t45 )); then
		$ipmitoolFull $f35
		echo "Current Fan Percentage: 35%"
	elif (( temp < t50 )); then
		$ipmitoolFull $f35
		echo "Current Fan Percentage: 35%"
	elif (( temp < t55 )); then
		$ipmitoolFull $f40
		echo "Current Fan Percentage: 40%"
	elif (( temp < t60 )); then
		$ipmitoolFull $f60
		echo "Current Fan Percentage: 60%"
	elif (( temp < t65 )); then
		$ipmitoolFull $f65
		echo "Current Fan Percentage: 65%"
	elif (( temp < t70 )); then
		$ipmitoolFull $f70
		echo "Current Fan Percentage: 70%"
	elif (( temp < t75 )); then
		$ipmitoolFull $f75
		echo "Current Fan Percentage: 75%"
	elif (( temp < t80 )); then
		$ipmitoolFull $f80
		echo "Current Fan Percentage: 80%"
	elif (( temp < t85 )); then
		$ipmitoolFull $f85
		echo "Current Fan Percentage: 85%"
	elif (( temp < t90 )); then
		$ipmitoolFull $f90
		echo "Current Fan Percentage: 90%"
	elif (( temp < t95 )); then
		$ipmitoolFull $f95
		echo "Current Fan Percentage: 95%"
	else (( temp < t100 ));
		$ipmitoolFull $f100
		echo "Current Fan Percentage: 100%"
	fi

echo "===================Temps For System===================="
cat "[replace/path]ipmi_temperature_cache.txt"
echo "======================================================="
echo ""
echo "Last Updated: $last_date_time"
sleep 30
clear
done
}

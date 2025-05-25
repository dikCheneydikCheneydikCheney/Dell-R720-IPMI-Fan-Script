# Dell R720 IPMI Fan Script

Howdy! I wrote out this script to fix an existing problem that I was experiencing with my hardware. TLDR: the fans on my R720 are too loud, and atm I don't have anywhere else to store it that isn't inconvenient. 
So, I wrote this script.

The entire script is a bash script using one tool, IPMI. If you don't know what IPMI is, click [here](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface)

# How this script works

There are two main functions; "grab_ipmi_temp_data" which grabs temperature data from the machine. The next function, "get_cpu_temp" uses piped grap and awk commands to **ONLY** pull the 3rd temp value from the temp data function. **If you want to change this, make sure to edit the | awk 'NR==3" | line. This determines the line you want to read from. 

Temps are measured in "t" variables with a number aside it, EX: **t**50
Fan Percentage is in "f" variables with a number aside it, EX: **f**50

Finally, the main part of the script is a massive if, elif, else statement. It pulls the current temp value and performs "less than" to the temperature value. If the temp is less than the number met, it then puts the R720 fans at a predetermined fan speed (which is in the Fan variables)

```
EXAMPLE:
	if (( temp <  t40 )); then
		$ipmitoolFull $f30
		echo "Current Fan Percentage: 30%"
	elif (( temp < t45 )); then
		$ipmitoolFull $f35
		echo "Current Fan Percentage: 35%"
```
# Where do I run this script?
**DO NOT RUN THIS IN ENTERPRISE ENVIRONMENTS! [THIS IS WHY!](https://www.rapid7.com/blog/post/2013/07/02/a-penetration-testers-guide-to-ipmi/)**
If you do run this script in a more critical environment, first, why? Second, only allow outbound and inbound traffic from the server that you're attempting to reach. Next only allow inbound traffic from your trusted machine to your iDRAC. This is to limit your attack surface. But if you take this advice from a dude named "dikcheney" on github you may have more problems than you think

Personally, I wrote this for my home lab. This script is on one Raspberry Pi with a physical screen so I can watch temps live. If I want to remotely check temps, I can just check my iDRAC. 

![thanks](https://github.com/user-attachments/assets/a93fcd9c-dd5a-49d8-b2e4-12ba635061e9)

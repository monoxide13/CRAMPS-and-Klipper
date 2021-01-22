#!/bin/bash

# The following comment section was taken from MachineKit, which I believe does a simular thing...

# Any GPIO pins driven by the PRU need to have their direction set properly
# here.  The PRU does not do any setup of the GPIO, it just yanks on the
# pins and assumes you have the output enables configured already
# 
# Direct PRU inputs and outputs do not need to be configured here, the pin
# mux setup (which is handled by the device tree overlay) should be all
# the setup needed.

# My understanding is that even though I set the pin mux in the device tree, I still need to tell linux that these pins are used.
# As for the second part about PRU inputs and outpus, I have no idea what that means because I could not get anything working by only loading the device tree.

######   DEFINE PINS   #####

pinArray=(

### PWR CTL ###
"49 out" #Machine Power
"50 out" #Motor Enable
"61 out" #EStop switch out from software
"27 in"  #EStop in from button
"127 out" #Status LED

### ENDSTOPS ###
"67 in"  #X Min
"66 in"  #X Max
"68 in"  #Y Min
"69 in"  #Y Max
"31 in"  #Z Min
"30 in"  #Z Max

### STEP N DIRECTION ###
"23 out" #X Step
"44 out" #X Dir
"47 out" #Y Step
"26 out" #Y Dir
"22 out" #Z Step
"65 out" #Z Dir
"51 out" #E0 Step
"60 out" #E0 Dir
"5 out"  #E1 Step
"4 out"  #E1 Dir
"15 out" #E2 Step
"14 out" #E2 Dir

### FETS ###
"45 out" #1
"48 out" #2
"125 out" #3
"3 out"  #4
"20 out" #5
"2 out"  #6

)

######   START SCRIPT   ######

if [ "$EUID" -ne 0 ]; then
	echo "Must run with sudo or as root"
	exit
fi

for i in ${!pinArray[@]};
do
	echo "Setting: ${pinArray[i]}"
	setting=(${pinArray[i]})
	if [ -d "/sys/class/gpio/gpio${setting[0]}" ]; then
		echo "  Pin already exported, unexporting."
		echo ${setting[0]} > /sys/class/gpio/unexport
		if [ $? -ne 0 ]; then
			echo "  Error unexporting!"
		fi
	fi
	echo ${setting[0]} > /sys/class/gpio/export
	if [ $? -eq 0 ]; then
		echo ${setting[1]} > /sys/class/gpio/gpio${setting[0]}/direction
		if [ $? -ne 0 ]; then
			echo "  Error setting direction!"
		fi
	else
		echo "  Error exporting!"
	fi
done


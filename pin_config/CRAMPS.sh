#!/bin/bash

#
# Any GPIO pins driven by the PRU need to have their direction set properly
# here.  The PRU does not do any setup of the GPIO, it just yanks on the
# pins and assumes you have the output enables configured already
# 
# Direct PRU inputs and outputs do not need to be configured here, the pin
# mux setup (which is handled by the device tree overlay) should be all
# the setup needed.
pinArray=(
"67 in" #X Min
"66 in" #X Max
"68 in" #Y Min
"69 in" #Y Max
"31 in" #Z Min
"30 in" #Z Max

#P8_11 low #FET 1 : Heated Bed
#P8_12 low #X Dir Used in PRU
#P8_13 low #X Step Used in PRU
#P8_14 low #Y Dir Used in PRU
#P8_15 low #Y Step Used in PRU
#P8_16 high #eMMC Enable
#P8_17 in #Estop In
#P8_18 low #Z Dir Used in PRU
#P8_19 low #Z Step Used in PRU
#P8_20 default
#P8_21 default
#P8_22 low #Servo 4
#P8_23 low #Servo 3
#P8_24 low #Servo 2
#P8_25 low #Servo 1
#P8_26 high #Estop out
#P9_11 in #Z Max
#P9_12 low #E0 Dir Used in PRU
#P9_13 in #Z Min
#P9_14 high #Axis Enable, act. low
#P9_15 low #FET 2 : E0
#P9_16 low #E0 Step Used in PRU
#P9_17 low #E1 Step Used in PRU
#P9_18 low #E1 Dir Used in PRU
#P9_21 low #FET 4 : E1
#P9_22 low #FET 6
#P9_23 low #Machine Power
#P9_24 low #E2 Step
#P9_25 low #LED
#P9_26 low #E2 Dir
#P9_27 low #FET 3 : E2
#P9_28 spi #SPI CS0
#P9_29 spi #SPI MISO
#P9_30 spi #SPI MOSI
#P9_31 spi #SPI SCLK
#P9_41 low #FET 5
#P9_42 spics #SPI CS1
#P9_91 in #Reserved, con. to P9.41 
#P9_92 in #Reserved, to P9.42
)

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


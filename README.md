# CRAMPS
This repo is where you'll find the device tree files and instructions on how to be able to use CRAMPS on the Beagle Board Black. This has changed a lot over recent years, so if it becomes out of date again please open an issue.

#NO WORKEE.
This code is still in developement. Mainly because I'm still trying to figure out the loading of DTO into UBOOT...

## What is CRAMPS?
[CRAMPS](https://github.com/cdsteinkuehler/bobc_hardware/tree/CRAMPS/CRAMPS) is a cape for the [Beagle Bone Black](https://beagleboard.org/black). It allows control of 6 stepper motors using Pololu Drivers and multiple FETs. It also has inputs for 6 end stops, 4 thermistors, and an E-stop. CRAMPS originated from RAMPS, which was designed for an Arduino.

The advantage of using the Beagle Bone Black (BBB) is that the BBB has 2 onboard Programable Realtime Units (PRU). These PRUs allow realtime control of devices via the BBB GPIO pins. This allows Linux to load the PRUs with the motion commands, and the PRUs control the motion and timing. Linus is therefore free to run other control software such as Octopi.

Most CRAMPS boards are used in 3D Printers and other CNC machines.

## What is a Device Tree?
Many years ago board manufactures were submitting their board files to be included in the Linux kernel. That file would define available pins and capabilites of that board. With so many different boards being produced, it became a lot of unnecessary bloat. It was decided a new method was needed, and thus device trees.

A device tree is a binary file that can be loaded dynamically or with u-boot on startup. It defines all the pins that are used as well as direction and pull-up or pull-down as needed.

## How do I compile and install the device tree?
We can dynamically load the device tree (CRAMPS.dts) by the command <code>echo CRAMPS.dts > /sys/devices/bone_capemgr.?/slots</code>

For permanent installation it's best to load via u-boot.

Compile and save the device tree to the firmware folder.
<code>dtc -O dtb -I dts -o /lib/firmware/CRAMPS.dtbo -b 0 -@ CRAMPS.dts</code>
Then in /boot/uEnv.txt change "enable_uboot_overlays=0" to "enable_uboot_overlays=1", and change "#uboot_overlay_addr0=..." to "uboot_overlay_addr0=/lib/firmware/CRAMPS.dtbo".

# DEVICE TREE OVERLAY

## What is a Device Tree?
Many years ago board manufactures were submitting their board files to be included in the Linux kernel. That file would define available pins and capabilites of that board. With so many different boards being produced, it became a lot of unnecessary bloat. It was decided a new method was needed, and thus device trees.

We used to be able to use device tree "slots" for dynamic loading. This method came with a lot of problems and lacked important features.
The new method is loading device tree overlays (DTO's) wtih U-Boot, which will take all device trees, flatten them into one, and pass it along to the linux kernal for boot.

## Why use the Device Tree Overlays?
DTOs are a much more convienent way of configuring pins at boot. Alternatively (as of now since I can't get the DTO working), the pins can be configured by exporting them to the Linux kernel.
See the main README for instructions on running the script.

## How do I compile and install the device tree?
	make
	sudo make install

In /boot/uEnv.txt, make the following changes. You may need to uncomment these by removing the first char '#'.

	dtb=/lib/firmware/BB-NHDMI-TDA998x-00A0.dtbo
	enable_uboot_overlays=1
	dtb_overlay=/lib/firmware/CRAMPS-00A0.dtbo

The following two I believe are not needed to be uncommented, but I haven't confirmed. So for now, uncomment.

	disable_uboot_overlay_emmc=1;
	disable_uboot_overlay_audio=1;

After installing and rebooting, check to see if the trees are loaded. <code>sudo /opt/scripts/tools/version.sh | grep -i UBOOT</code> This should return something simular to the following. Note that our overlay is displayed as an option.

	UBOOT: Booted Device-Tree:[am335x-boneblack-uboot.dts]
	UBOOT: Loaded Overlay:[AM335X-PRU-RPROC-4-14-TI-00A0]
	UBOOT: Loaded Overlay:[BB-ADC-00A0]
	UBOOT: Loaded Overlay:[BB-NHDMI-TDA998x-00A0]
	uboot_overlay_options:[enable_uboot_overlays=1]
	uboot_overlay_options:[disable_uboot_overlay_emmc=1]
	uboot_overlay_options:[disable_uboot_overlay_audio=1]
	uboot_overlay_options:[uboot_overlay_pru=/lib/firmware/AM335X-PRU-RPROC-4-14-TI-00A0.dtbo]
	uboot_overlay_options:[dtb_overlay=/lib/firmware/CRAMPS-00A0.dtbo]

## Gotcha's for the new players...

### U-Boot version
The debian version I originally installed had an old version of U-Boot. Updating should be the first thing you do before going through the work of setting up the DTO.
U-Boot version can be checked by running:

	sudo /opt/scripts/tools/version.sh | grep bootloader

U-Boot can be updated by running the following as root (sudo su):

	cd /opt/scripts
	git pull
	./tools/developers/update_bootloader.sh
	reboot

### Device Tree Compiler Version
It is know on some systems the DTC may be out of date. If you get an error during make about the "-@" flag, it needs updating.
Update with these commands:

	wget -c https://raw.githubusercontent.com/RobertCNelson/tools/master/pkgs/dtc.sh
	chmod +x dtc.sh
	sudo ./dtc.sh



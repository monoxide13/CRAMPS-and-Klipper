# CRAMPS and Klipper on the Beaglebone
This repo is where you'll find the device tree files and instructions on how to be able to use CRAMPS on the Beagle Board Black. This has changed a lot over recent years, so if it becomes out of date again please open an issue.

##STATUS
This code is still in developement. Most of the command I've tested but are transposed over. If you come across errors please create an issue.
Written for Debian 10.3

###TODO:
Write script to configure pins.
Figure out the loading of DTO into UBOOT.
Create working configuration file for Klipper.

## What is CRAMPS?
[CRAMPS](https://github.com/cdsteinkuehler/bobc_hardware/tree/CRAMPS/CRAMPS) is a cape for the [Beagle Bone Black](https://beagleboard.org/black). It allows control of 6 stepper motors using Pololu Drivers and control of heaters and outputs via multiple FETs. It also has inputs for 6 end stops, 4 thermistors, and an E-stop. CRAMPS originated from RAMPS, which was designed for an Arduino.

The advantage of using the Beagle Bone Black (BBB) is that the BBB has 2 onboard Programable Realtime Units (PRU). These PRUs allow realtime control of devices via the BBB GPIO pins. This allows Linux to load the PRUs with the motion commands, and the PRUs control the motion and timing. Linus is therefore free to run other control software such as Octopi.

## What is Klipper?
[Klipper](https://www.klipper3d.org) is a 3d printer firmware. It takes in the G-Code commands via serial and converts that into motion (step-and-direction) and turning the heaters on and off. It is the software/firmware that actually flips the pins telling the electronics what to do. Klipper uses the PRUs on the Beagle Bone to do most of this without Linux interference. I'm using Octoprint to send the serial commands to Klipper for control.

## Instructions:
I'm starting from a blank install of Debian 10.3 IOT and booting the Beagle Bone from the SD card. If you didn't expand the filesystem after writing debian to the SD, it can be done on the Beagle Bone with "/opt/scripts/tools/grow_partition.sh".

### Update and configure system
First step is to make sure our system is up to date. If you need to connect to wifi use "/opt/scripts/network/wifi_enterprise.sh"
<code>
sudo apt-get update
sudo apt-get upgrade
cd /opt/scripts
git pull
/opt/scripts/tools/update_kernel.sh
/opt/scripts/tools/developers/update_bootloader.sh
shutdown -r now
</code>

Now we have to edit the boot file. In /boot/uEnv.txt, uncomment the following two lines.
<code>
disable_uboot_overlay_emmc=1
disable_uboot_overlay_audio=1
</code>

### Build the Device Tree Blob and configure pins
The device tree is used to configure the pins at startup. It does not define the pins in Linux, only sets the pin mux.
MORE NEEDED HERE...


### Download and Install Octoprint
Octoprint requires Python 3.6+. The latest version of Python on Debian 10.3 at the time of writing is 3.7

This section will install Python 3.9 if for some reason you want it. If you are going to use 3.7 as installed, skip to the bottom of this section.
<code>
sudo apt-get install build-essential zlib1g-dev libncurses5-dev libgdm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev curl libbz2-dev
cd ~/
wget https://www.python.org/ftp/python/3.9.1/Python-3.9.1.tar.xz
tar xf Python-3.9.1.tar.xz
cd Python-3.9.1
</code>
The next command will configure Python for our system and make sure all dependencies are installed. The "--enable-optimizations" flag will tell Python to try optimizing the code. This will cause Python to take longer to build but will increase it's execution speed. This flag is technically optional, but I highly recommend it.
<code>
./configure --enable-optimizations
</code>
Time to compile Python. This will take a long time! 3ish hours.
<code>
make
</code>
If you want to make this version of Python the default, run "sudo make install" instead of the following. I recommend not.
<code>
sudo make altinstall
</code>
Verify the version by running "python3.9 --version".
Create the virtual environment.
<code>
python3.9 -m venv octoprint
</code>

Using python 3.7? Use the following to install the required packages from the repo.
<code>
sudo apt-get install python3-pip python3-dev python3-setuptools python3-venv libyaml-dev build-essential
python3.7 -m venv octoprint
</code>

Now use the virtual envirnment to install and then run Octoprint.
<code>
source octoprint/bin/activate
pip install pip --upgrade
pip install octoprint
octoprint/bin/octoprint serve
</code>

Navigate to http://<IP>:5000 and go through the Octoprint setup.

After setup, we need to add a Serial Port to Octoprint. Click on the Settings tab, and under Serial Port add "/tmp/printer" to "Additional serial ports".

Set Octoprint to start on boot. After downloading the service file, change "User=" to be your user, and "ExecStart=" to be the path of installation (/home/debian/octoprint/bin/octoprint).
<code>
wget https://github.com/Octoprint/Octoprint/raw/master/scripts/octoprint.service
sudo mv octoprint.service /etc/systemd/system/octoprint.service
sudo systemctl enable octoprint.service
</code>

Add the current user to the dialout groups.
<code>
sudo usermod -a -G tty debian
sudo usermod -a -G dialout debian
</code>

Now is a good time to reboot. It will reload the user permission we just added, and will verify Octoprint is working and loading.

### Download and Install Klipper
I'm basing my instructions off of [Klippers instructions](https://www.klipper3d.org/beaglebone.html).
Download klipper by using...
<code>git clone https://github.com/KevinOConnor/klipper</code>

First we need to patch the original debian and beaglebone install scripts.
<code>
wget https://raw.githubusercontent.com/monoxide13/CRAMPS-and-Klipper/master/klipper_debian.patch
wget https://raw.githubusercontent.com/monoxide13/CRAMPS-and-Klipper/master/klipper_beaglebone.patch
patch -u klipper/scripts/install-debian.sh -i klipper_debian.patch
patch -u scripts/install-beaglebone.sh -i klipper_beaglebone.patch
</code>
Now install Klippers dependencies and serviced files.
<code>
klipper/scripts/install_beaglebone.sh
</code>
First we'll compile Klippers PRU program. When you run "make menuconfig" below, select "Beaglebone PRU".
<code>
make menuconfig
make flash
</code>
Now run the above two commands again, but this time in menuconfig, select "Linux process".

### Configuration
So now we should have 3 programs that run at boot via systemd: octoprint, klipper_pru, and klipper.

Klipper uses it's own configuration file. I've included mine for reference, "printer.cfg". This file needs to sit in your home directory "~/". This file needs to be set up correctly before starting Klipper. Copy/edit this file as needed, then run the included script "restart_klipper.sh".

To check for completeness and correctness of the file, check the log file at "/tmp/klippy.log". I found it also helpful to go into octoprint and connect to the printer, and in the terminal send "help". This will list all available commands. If something is wrong with your file you'll notice it'll only give you 4 or 5 commands. If you send "status" klipper will either crash and return the line it of the error, or if everything is OK it'll return "READY".

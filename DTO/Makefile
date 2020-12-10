# CRAMPS device tree overlay

VERSION := 00A0

default: CRAMPS-$(VERSION).dtbo

CRAMPS-$(VERSION).dtbo: CRAMPS.dts
	dtc -O dtb -I dts -o CRAMPS-$(VERSION).dtbo -b 0 -@ CRAMPS.dts
	@if [ $$? -eq 1 ]; then exit; fi
	@echo "Completed! Output file: CRAMPS-$(VERSION)"
	@echo "Run \"sudo make install\" to install to /lib/firmware"

install: CRAMPS-$(VERSION).dtbo
	sudo cp CRAMPS-$(VERSION).dtbo /lib/firmware/

clean:
	rm -fv *.dtbo

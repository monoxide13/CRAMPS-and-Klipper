#!/bin/bash -ev
sudo systemctl stop klipper
sudo systemctl restart klipper_pru
sudo systemctl start klipper

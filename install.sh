#!/bin/bash
sudo cp -Rv var/* /var
sudo cp -Rv usr/* /usr
sudo cp -Rv etc/* /etc
sudo systemctl enable battery_charge_threshold.service --now
sudo systemctl enable headset.service --now
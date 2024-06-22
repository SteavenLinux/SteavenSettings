#!/bin/bash
sudo cp -Rv var/* /var
sudo cp -Rv usr/* /usr
sudo cp -Rv etc/* /etc
cp -Rv $PWD/home/user/.config/systemd/user/headset.service ~/.config/systemd/user/headset.service
sudo systemctl enable battery_charge_threshold.service --now
sudo systemctl enable headset.service --now
systemctl --user enable headset.service --now
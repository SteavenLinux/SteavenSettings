# SteavenSettings
This repository contains configuration files that tweak sysctl values, add udev rules to automatically set schedulers, and provide additional optimizations.

## udev rules
- Audio latency
- SATA Active Link Power Management for HDD to prioritize max performance 
- IO schedulers, automatic selection schedulers depends on your HW - SATA SSD, NVME and HDD.
- NVIDIA, load, unload modules and set-up power management. 
- Fix headset on connect
- Disable nintdido switch for android controllers to make it use xbox mode
- Enable Sunshine app
- Arduino Support
- Show intel cpu wats in mangohud
- Make cpu run at max mhz when changer is connected and when its discconted then run cpu at power save
- Use ntfs3 drivers by default
- Zram 16GB (add `/dev/zram0 none swap defaults,pri=100 0 0` in `/etc/fstab` for it to work)

## makepkg.conf.d
- MAKEFLAGS to use all cpu cores

## sysctl
- Fixs Game Compatibilty Problems

## modprobe
- NVIDIA and enable direct rendering
- Force using of the amdgpu driver for Southern Islands (GCN 1.0+) and Sea Islands (GCN 2.0+).
- v4l2loopback config For obs virutal Camera support
- kvmfr config for Looking Glass

## pipewire.d
- Allowed rates only is 48kbps
- Changed default.clock.quantum to 2058
- Changed default.clock.min-quantum to 1024

## conf.d
- libvirt-guests Config to Stop vm correcntly on Linux Shutdown

## NetworkManager
- Disable Wifi Sleep to reduce Wifi Delay

## systemd
- Reduce Systemd start and stop service wait time, start to 15s and stop to 10s
- Redcuce journal size to 50M
- Reduce user@service stop time from 120s to 10s
- Headset fix script for system and user
- Disable Systemd Core Dumping to prevent / disk i/o usage from beening at 100% when anything wants to crash

## udisks2
- Custom Default mount options
- ntfs has `uid=1000,gid=1000,rw,user,exec,umask=000,windows_names,nofail,nosuid,nodev,x-gvfs-show`
- btrfs has `autodefrag,space_cache=v2,noatime,nodiratime,commit=120,nofail,nosuid,nodev,x-gvfs-show,rw,user,exec`
- ext4 has `noatime,nodiratime,nosuid,nodev,x-gvfs-show,rw,exec`

## grub
- Improved Cpu Mitigations
- Distrust Cpu
- Enabled Iommu support

## environment
- Set default cli editor to Nano
- Make firefox run using xwayland on wayland to fix crashs when using nvidia drivers 555
- Enable mangohud and obs vkcapture and vkbaslt by default
- Incress shader cache size and keep old one

## Scripts
- `amd-gpu-run` to run apps using amd gpu
- `intel-gpu-run` to run apps using intel gpu
- `nouveau-gpu-run` to run apps using nouveau gpu
- `nvidia-gpu-run` to run apps using nvidia gpu
- `killpicom` to kill picom then reopen it put it in steam game argements like this `killpicom %command%`

# Installtion

run install.sh

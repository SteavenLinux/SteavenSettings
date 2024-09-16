# SteavenSettings
This repository contains configuration files that tweak sysctl values, add udev rules to automatically set schedulers, and provide additional optimizations.

That can work on Arch Linux and Fedora.

## My pc and laptop Settings
- [PC-PersonalSettings](https://github.com/SteavenLinux/PC-PersonalSettings)
- [Laptop-PersonalSettings](https://github.com/SteavenLinux/Laptop-PersonalSettings)

## More Settings
- [ArchSettings](https://github.com/SteavenLinux/ArchSettings)
- [FedoraSettings](https://github.com/SteavenLinux/FedoraSettings)

## udev rules
- Audio latency
- SATA Active Link Power Management for HDD to prioritize max performance 
- IO schedulers, automatic selection schedulers depends on your HW - SATA SSD, NVME and HDD.
- NVIDIA, load, unload modules and set-up power management. 
- Enable Sunshine app
- Arduino Support
- Show intel cpu wats in mangohud
- Make cpu run at max mhz when changer is connected and when its discconted then run cpu at power save
- Use ntfs3 drivers by default

## sysctl
- Fixs Game Compatibilty Problems

## modprobe
- NVIDIA and enable direct rendering
- NVIDIA enable brightness control
- Force using of the amdgpu driver for Southern Islands (GCN 1.0+) and Sea Islands (GCN 2.0+).
- Enable amndgpu Control
- v4l2loopback config For obs virutal Camera support
- kvmfr config for Looking Glass

## conf.d
- libvirt-guests Config to Stop vm correcntly on Linux Shutdown

## NetworkManager
- Disable Wifi Sleep to reduce Wifi Delay

## systemd
- Reduce Systemd start and stop service wait time, start to 15s and stop to 10s
- Redcuce journal size to 50M
- Reduce user@service stop time from 120s to 10s
- Disable Systemd Core Dumping to prevent disk i/o usage from beening at 100% when anything wants to crash

## udisks2
- Custom Default mount options
- ntfs has `1000,gid=1000,rw,exec,umask=000,windows_names,nofail,nosuid,nodev,x-gvfs-show`
- btrfs has `autodefrag,space_cache=v2,noatime,nodiratime,commit=120,nofail,nosuid,nodev,x-gvfs-show,rw,user,exec`
- ext4 has `noatime,nodiratime,nosuid,nodev,x-gvfs-show,rw,exec`

## grub
- Improved Cpu Mitigations
- Distrust Cpu
- Enabled Iommu support

## environment
- Set default cli editor to Nano

## Scripts
- `amd-gpu-run` to run apps using amd gpu
- `intel-gpu-run` to run apps using intel gpu
- `nouveau-gpu-run` to run apps using nouveau gpu
- `nvidia-gpu-run` to run apps using nvidia gpu
- `killpicom` to kill picom then reopen it put it in steam game argements like this `killpicom %command%`
- `game-run` to run game with this envs Enable mangohud and obs vkcapture and vkbaslt by default, Incress shader cache size and keep old one, forces vsync on nvidia gpus

# Polkit Rules
- Shutdown and Reboot without needing to use sudo

# Installtion

run install.sh

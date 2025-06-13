# /etc/nixos/optimized-config.nix

{ config, pkgs, lib, ... }:
{
  imports = [ ];

  # Kernel modules and options
  boot.kernelModules = [ "kvmfr" "ntsync" "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
    options amdgpu si_support=1 cik_support=1
    options radeon si_support=0 cik_support=0
    options amdgpu ppfeaturemask=0xFFFFFFFF
    options kvmfr static_size_mb=32
    options nvidia NVreg_UsePageAttributeTable=1
    options nvidia NVreg_DynamicPowerManagement=0x02
    options nvidia NVreg_RegistryDwords=EnableBrightnessControl=1
    options nvidia_drm modeset=1
    options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
    options v4l2loopback exclusive_caps=1 card_label="OBS Virtual Camera"
  '';

  # Systemd settings
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=15s
    DefaultTimeoutStopSec=10s
  '';

  systemd.services."your-service".serviceConfig.TimeoutStopSec = lib.mkDefault "10s";
  services.journald.extraConfig = ''
    SystemMaxUse=50M
  '';

  # sysctl settings
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };

  # Timesyncd replacement with Chrony
  services.chrony = {
    enable = true;
    extraConfig = ''
      server time.cloudflare.com iburst nts
      server ntppool1.time.nl iburst nts
      server nts.netnod.se iburst nts
      server ptbtime1.ptb.de iburst nts
      server time.dfm.dk iburst nts
      server time.cifelli.xyz iburst nts

      minsources 3
      authselectmode require

      # EF
      dscp 46

      driftfile /var/lib/chrony/drift
      ntsdumpdir /var/lib/chrony

      leapsectz right/UTC
      makestep 1.0 3

      rtconutc

      cmdport 0

      noclientlog
    '';
  };

  # Polkit rules
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.Flatpak.app-install" ||
             action.id == "org.freedesktop.Flatpak.runtime-install" ||
             action.id == "org.freedesktop.Flatpak.app-uninstall" ||
             action.id == "org.freedesktop.Flatpak.metadata-update" ||
             action.id == "org.freedesktop.Flatpak.appstream-update" ||
             action.id == "org.freedesktop.Flatpak.runtime-uninstall" ||
             action.id == "org.freedesktop.Flatpak.modify-repo") &&
            subject.active == true &&
            subject.isInGroup("wheel")) {
                return polkit.Result.YES;
        }

        return polkit.Result.NOT_HANDLED;
    });
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.login1.power-off" ||
             action.id == "org.freedesktop.login1.reboot" ||
             action.id == "org.freedesktop.login1.suspend" ||
             action.id == "org.freedesktop.login1.hibernate") &&
            subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
    });
  '';

  # NetworkManager config
  networking.networkmanager.enable = true;
  networking.networkmanager.settings = {
    "connection" = {
        "wifi.powersave" = 2;
    };
  };  

  # ZRAM configuration
  services.zram-generator = {
    enable = true;
    settings = {
        zram0 = {
            "compression-algorithm" = "zstd";  # ← string, not a list
            "zram-size" = lib.mkForce "ram";               # ← valid value (uses all RAM)
            "swap-priority" = 100;
            "fs-type" = "swap";
        };
    };
  };

  # Udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", TEST=="/sys/module/snd_hda_intel", \
        RUN+="${pkgs.bash}/bin/bash -c 'echo $$(cat /run/udev/snd-hda-intel-powersave 2>/dev/null || echo 10) > /sys/module/snd_hda_intel/parameters/power_save'"

    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", TEST=="/sys/module/snd_hda_intel", \
        RUN+="${pkgs.bash}/bin/bash -c '[[ $$(cat /sys/module/snd_hda_intel/parameters/power_save) != 0 ]] && echo $$(cat /sys/module/snd_hda_intel/parameters/power_save) > /run/udev/snd-hda-intel-powersave; echo 0 > /sys/module/snd_hda_intel/parameters/power_save'"

    ACTION=="change", KERNEL=="zram0", ATTR{initstate}=="1", SYSCTL{vm.swappiness}="150", \
        RUN+="${pkgs.bash}/bin/bash -c 'echo N > /sys/module/zswap/parameters/enabled'"

    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"

    ACTION=="add|change", SUBSYSTEMS=="usb", ATTR{power/autosuspend}="-1"
    ACTION=="add|change", SUBSYSTEMS=="usb", ATTR{power/autosuspend_delay_ms}="-1"
    ACTION=="add|change", SUBSYSTEMS=="input", ATTR{power/autosuspend}="-1"
    ACTION=="add|change", SUBSYSTEMS=="input", ATTR{power/autosuspend_delay_ms}="-1"

    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="*", ATTR{link_power_management_policy}="max_performance"

    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"

    ACTION=="add|bind", SUBSYSTEM=="pci", DRIVERS=="nvidia", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="remove|unbind", SUBSYSTEM=="pci", DRIVERS=="nvidia", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", TEST=="power/control", ATTR{power/control}="on"

    SUBSYSTEM=="cpu", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'if grep -q GenuineIntel /proc/cpuinfo; then chmod o+r /sys/class/powercap/intel-rapl:0/energy_uj; fi'"


    SUBSYSTEM=="block", TEST!="${pkgs.ntfs3g}/bin/ntfs-3g", ENV{ID_FS_TYPE}=="ntfs", ENV{ID_FS_TYPE}="ntfs3"

    KERNEL=="ntsync", MODE="0644"
  '';

  # UDisks2 mount options
  services.udisks2.settings = {
  "mount_options.conf" = {
    defaults = {
      ntfs_defaults = "uid=1000,gid=1000,rw,exec,umask=000,windows_names,nofail,nosuid,nodev,x-gvfs-show";
      btrfs_defaults = "autodefrag,space_cache=v2,noatime,nodiratime,commit=120,nofail,nosuid,nodev,x-gvfs-show,rw,user,exec";
      ext4_defaults = "noatime,nodiratime,nosuid,nodev,x-gvfs-show,rw,exec";
    };
  };
};
}

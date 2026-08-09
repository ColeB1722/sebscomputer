{ ... }:
{
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.supportedFilesystems = [
    "ntfs"
    "zfs"
  ];

  boot.zfs.forceImportRoot = false;

  networking.hostId = "c17e5b50";

  boot.extraModprobeConfig = ''
    options zfs zfs_arc_max=8589934592
  '';

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "monthly";
    };
    trim.enable = true;
  };

  services.sanoid = {
    enable = true;
    datasets = {
      "tank/home" = {
        useTemplate = [ "protected" ];
        recursive = true;
      };
      "tank/data" = {
        useTemplate = [ "protected" ];
        recursive = true;
      };
    };
    templates.protected = {
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 6;
      autosnap = true;
      autoprune = true;
    };
  };
}

{ lib, ... }:
let
  phase0Placeholder = "/dev/disk/by-id/PHASE1_REPLACE_WITH_NEW_NVME_BY_ID";
  targetDisk = phase0Placeholder;
in
{
  assertions = [
    {
      assertion = targetDisk == phase0Placeholder;
      message = ''
        Phase 0 must use the nonexistent disk placeholder. In Phase 1, replace
        targetDisk and this assertion only after recording and verifying the new
        drive's live model, serial, capacity, partition state, and by-id path.
      '';
    }
    {
      assertion = lib.hasPrefix "/dev/disk/by-id/" targetDisk;
      message = "The disko target must use a stable /dev/disk/by-id/ path.";
    }
  ];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = targetDisk;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          zfs = {
            priority = 2;
            size = "100%";
            type = "BF01";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
    };

    zpool.tank = {
      type = "zpool";
      options.ashift = "12";
      rootFsOptions = {
        acltype = "posixacl";
        compression = "zstd";
        mountpoint = "none";
        xattr = "sa";
        "com.sun:auto-snapshot" = "false";
      };

      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = "legacy";
        };
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options = {
            atime = "off";
            mountpoint = "legacy";
          };
        };
        var = {
          type = "zfs_fs";
          mountpoint = "/var";
          options.mountpoint = "legacy";
        };
        home = {
          type = "zfs_fs";
          mountpoint = "/home";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };
        data = {
          type = "zfs_fs";
          mountpoint = "/data";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };
        vm = {
          type = "zfs_fs";
          options.mountpoint = "none";
        };
        "vm/images" = {
          type = "zfs_fs";
          options.mountpoint = "none";
        };
        "vm/volumes" = {
          type = "zfs_fs";
          options.mountpoint = "none";
        };
      };
    };
  };
}

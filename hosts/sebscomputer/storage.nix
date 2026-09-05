{ lib, ... }:
let
  # Phase 1 identity, recorded live and signed off 2026-09-05 (CB) in
  # transition-evidence/procedures/PHASE1-RECORD.md: physical label ==
  # Windows Get-Disk AdapterSerialNumber == installer by-id, serial
  # QH7499W100762P3100 (Lexar NQ780 2 TB, zero partitions at capture).
  # Copied from reports/phase2-boot-a/by-id.txt, not typed from memory.
  phase1RecordedPath = "/dev/disk/by-id/nvme-Lexar_SSD_NQ780_2TB_QH7499W100762P3100";
  targetDisk = phase1RecordedPath;
in
{
  assertions = [
    {
      assertion = targetDisk == phase1RecordedPath;
      message = ''
        The disko target must remain the Phase 1-recorded Lexar NQ780 by-id
        path. Changing it requires redoing the Phase 1 identity record and
        sign-off in transition-evidence, never an inline edit.
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

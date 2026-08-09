{
  description = "NixOS system configuration for sebscomputer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, disko, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      mkHost = import ./lib/mk-host.nix { inherit inputs; };
      host = mkHost {
        inherit system;
        modules = [ ./hosts/sebscomputer ];
      };
      storage = host.config.disko.devices;
      datasetSummary = name: {
        inherit name;
        inherit (storage.zpool.tank.datasets.${name}) type options;
        mountpoint = storage.zpool.tank.datasets.${name}.mountpoint or null;
      };
      storageSummary = {
        device = storage.disk.main.device;
        esp = {
          inherit (storage.disk.main.content.partitions.ESP) size type;
          inherit (storage.disk.main.content.partitions.ESP.content)
            format
            mountpoint
            mountOptions
            ;
        };
        zfsPartition = {
          inherit (storage.disk.main.content.partitions.zfs) size type;
          inherit (storage.disk.main.content.partitions.zfs.content) pool;
        };
        pool = {
          name = "tank";
          inherit (storage.zpool.tank) options rootFsOptions;
        };
        datasets = map datasetSummary [
          "root"
          "nix"
          "var"
          "home"
          "data"
          "vm"
          "vm/images"
          "vm/volumes"
        ];
      };
      storagePlan = pkgs.writeText "sebscomputer-storage-plan.json" (builtins.toJSON storageSummary);
      printStoragePlan = pkgs.writeShellApplication {
        name = "storage-plan";
        text = ''
          exec ${pkgs.jq}/bin/jq . ${storagePlan}
        '';
      };
      diskoPlan = pkgs.writeShellApplication {
        name = "disko-plan";
        text = ''
          exec ${disko.packages.${system}.disko}/bin/disko \
            --dry-run \
            --mode destroy,format,mount \
            --flake .#sebscomputer
        '';
      };
    in
    {
      nixosConfigurations.sebscomputer = host;

      formatter.${system} = pkgs.nixfmt;

      checks.${system} = {
        host = host.config.system.build.toplevel;
        storage = storagePlan;
      };

      apps.${system} = {
        disko-plan = {
          type = "app";
          program = "${diskoPlan}/bin/disko-plan";
        };
        storage-plan = {
          type = "app";
          program = "${printStoragePlan}/bin/storage-plan";
        };
      };
    };
}

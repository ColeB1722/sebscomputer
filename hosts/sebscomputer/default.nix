{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ../../modules/base.nix
    ../../modules/boot.nix
  ];

  networking.hostName = "sebscomputer";
  services.getty.helpLine = "sebscomputer: Phase 2 base-system validation.";
  system.stateVersion = "26.05";
}

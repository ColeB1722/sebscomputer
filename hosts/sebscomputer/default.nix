{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ../../modules/base.nix
    ../../modules/boot.nix
  ];

  networking.hostName = "sebscomputer";
  system.stateVersion = "26.05";
}

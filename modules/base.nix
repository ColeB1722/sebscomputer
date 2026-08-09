{ pkgs, ... }:
{
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  networking.networkmanager.enable = true;

  programs.fish.enable = true;

  users.users.coleb = {
    isNormalUser = true;
    description = "Cole Brown";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYEMoAMxPAGD4AzBPCAYV6UiHrAeMm/AJIGXKCikkuc"
    ];
  };

  users.users.root.hashedPassword = "!";
  security.sudo.wheelNeedsPassword = true;

  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  environment.systemPackages = with pkgs; [
    efibootmgr
    fish
    git
    nvme-cli
    pciutils
    smartmontools
    usbutils
  ];
}

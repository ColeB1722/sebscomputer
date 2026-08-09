{ inputs }:
{
  system,
  modules,
}:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = { inherit inputs; };

  modules = [ inputs.disko.nixosModules.disko ] ++ modules;
}

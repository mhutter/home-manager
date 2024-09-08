{ lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
  ];

  networking.hostName = "nxzt";

  # Graphics
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
  };

  # Gaming
  programs.steam = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraLibraries = pkgs: [ ];
      extraPkgs = pkgs: [ ];
    })
  ];
}

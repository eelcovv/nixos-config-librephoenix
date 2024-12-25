{ config, pkgs, userSettings, ... }:

{
  home.packages = [ pkgs.uv ];
  programs.uv.enable = true;
}

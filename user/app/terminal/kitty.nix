{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    kitty
  ];
  programs.kitty.enable = true;
  programs.kitty.settings = {
    shell_integration = "disabled";
    background_opacity = lib.mkForce "0.85";
    modify_font = "cell_width 90%";
  };
}

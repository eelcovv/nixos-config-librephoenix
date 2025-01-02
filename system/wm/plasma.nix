{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  #services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    oxygen
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    oxygen
  ];

  #Gnome
  environment.pathsToLink = ["/libexec"];
  services.xserver.desktopManager.gnome.enable = true;

  #cinnamon
  services.xserver.desktopManager.cinnamon.enable = true;

  # Hastag #icantdecidewhatmyfavouriteDEis :)
}

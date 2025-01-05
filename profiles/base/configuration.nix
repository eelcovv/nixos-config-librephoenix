# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, systemSettings, userSettings, ... }:
{
  imports =
    [ ../../system/hardware-configuration.nix
      ../../system/hardware/systemd.nix # systemd config
      ../../system/hardware/kernel.nix # Kernel config
      ../../system/hardware/power.nix # Power management
      ../../system/hardware/time.nix # Network time sync
      ../../system/hardware/opengl.nix
      ../../system/hardware/printing.nix
      ../../system/hardware/bluetooth.nix
      (./. + "../../../system/wm"+("/"+userSettings.wm)+".nix") # My window manager
      #../../system/app/flatpak.nix
      ../../system/app/virtualization.nix
      ( import ../../system/app/docker.nix {storageDriver = null; inherit pkgs userSettings lib;} )
      ../../system/security/doas.nix
      ../../system/security/gpg.nix
      ../../system/security/blocklist.nix
      ../../system/security/firewall.nix
      ../../system/security/firejail.nix
      ../../system/security/openvpn.nix
      ../../system/security/automount.nix
      ../../system/style/stylix.nix
    ];

  # Fix nix path
  nix.nixPath = [ "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
                  "nixos-config=$HOME/dotfiles/system/configuration.nix"
                  "/nix/var/nix/profiles/per-user/root/channels"
                ];

   # TODO: check for a solution for this. I copied this from /etc/nixos/configuration.nix,
   # but is should be loaded from here I think.
   # boot.initrd.luks.devices."luks-0bb5b2e7-2d53-43eb-92a4-80d50e74876f".device = "/dev/disk/by-uuid/0bb5b2e7-2d53-43eb-92a4-80d50e74876f";

  # Ensure nix flakes are enabled
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # add to ensure different sessions on login
  environment = {
    sessionVariables = {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_DESKTOP_DIR = "$HOME/Desktop";
    };

    variables = {
      # Make some programs "XDG" compliant.
      LESSHISTFILE = "$XDG_CACHE_HOME/less.history";
      WGETRC = "$XDG_CONFIG_HOME/wgetrc";
      XDG_TERMINAL = "alacritty";
      # Enable icons in tooling since we have nerdfonts.
      LOG_ICONS = "true";
    };

    shellAliases = {
      ".." = "cd ..";
      neofetch = "nitch";
      ls = "eza -la --icons --no-user --no-time --git -s type";
      cat = "bat";
    };
  };

  # nixpkgs.overlays = [
  #   (
  #     final: prev: {
  #       logseq = prev.logseq.overrideAttrs (oldAttrs: {
  #         postFixup = ''
  #           makeWrapper ${prev.electron_27}/bin/electron $out/bin/${oldAttrs.pname} \
  #             --set "LOCAL_GIT_DIRECTORY" ${prev.git} \
  #             --add-flags $out/share/${oldAttrs.pname}/resources/app \
  #             --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
  #             --prefix LD_LIBRARY_PATH : "${prev.lib.makeLibraryPath [ prev.stdenv.cc.cc.lib ]}"
  #         '';
  #       });
  #     }
  #   )
  # ];
 

  # # logseq
  # nixpkgs.config.permittedInsecurePackages = [
  #     "electron-27.3.11"
  # ];


  # I'm sorry Stallman-taichou
  nixpkgs.config.allowUnfree = true;

    # Enable bin files to run
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [
    # IMPORTANT:
    # put any missing dynamic libs for unpacking programs here,
    # NOT in environment.systemPackages
  ];

  nix = {
    settings = {
      trusted-users = ["@wheel" "root"];
      allowed-users = ["@wheel" "root"];

      experimental-features = "nix-command flakes";
      http-connections = 50;
      warn-dirty = false;
      log-lines = 50;

      sandbox = "relaxed";
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };
 };

  # Kernel modules
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "cpufreq_powersave" ];

  # Bootloader
  # Use systemd-boot if uefi, default to grub otherwise
  boot.loader.systemd-boot.enable = if (systemSettings.bootMode == "uefi") then true else false;
  boot.loader.efi.canTouchEfiVariables = if (systemSettings.bootMode == "uefi") then true else false;
  boot.loader.efi.efiSysMountPoint = systemSettings.bootMountPath; # does nothing if running bios rather than uefi
  boot.loader.grub.enable = if (systemSettings.bootMode == "uefi") then false else true;
  boot.loader.grub.device = systemSettings.grubDevice; # does nothing if running uefi rather than bios

  # Networking
  networking.hostName = systemSettings.hostname; # Define your hostname.
  networking.networkmanager.enable = true; # Use networkmanager

  # Timezone and locale
  time.timeZone = systemSettings.timezone; # time zone
  i18n.defaultLocale = systemSettings.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.locale;
    LC_IDENTIFICATION = systemSettings.locale;
    LC_MEASUREMENT = systemSettings.locale;
    LC_MONETARY = systemSettings.locale;
    LC_NAME = systemSettings.locale;
    LC_NUMERIC = systemSettings.locale;
    LC_PAPER = systemSettings.locale;
    LC_TELEPHONE = systemSettings.locale;
    LC_TIME = systemSettings.locale;
  };

  # User account
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" "input" "dialout" "video" "render" "fuse" ];
    packages = [];
    uid = 1000;
  };

# System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    cryptsetup
    home-manager
    wpa_supplicant
    sshfs
    openssh
    fuse
  ];

  fonts.fontDir.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # It is ok to leave this unchanged for compatibility purposes
  system.stateVersion = "22.11";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  services = {
    libinput.enable = true; # Enable touchpad support
    #TODO: play with tailscale
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
    flatpak.enable = true;
    usbmuxd.enable = true;
    deluge = {
      enable = true;
      # declarative = true;
    };

    openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
        # Enable SFTP subsystem
        Subsystem = "sftp internal-sftp";
      };

      # Consider changing this if you need SSH access from other machines
      listenAddresses = [
        {
          addr = "127.0.0.1";
          port = 22;
        }
        {
          addr = "::1";
          port = 22;
        }
      ];
    };
  };

  environment.etc."ssh/ssh_config".text = ''
    Host remote
      HostName remote
      User rudra
      Port 22
      ForwardX11 yes
      IdentityFile ~/.ssh/id_ed25519
      ServerAliveInterval 60
      ServerAliveCountMax 3
      Compression yes
  '';

  systemd.services.NetworkManager-wait-online.enable = false;

  # XFCE desktop manager (for Thunar preferences)
  services.xserver.desktopManager.xfce = {
    enable = true;
  };

  # Enable X11 forwarding
  services.xserver.enable = true;

  # Allow users in the "fuse" group to use FUSE
  users.groups.fuse = {};

  #Enable Sudo [REPLACED BY DOAS]
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
}

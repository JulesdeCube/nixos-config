# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    # systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;

    grub = {
      enable = true;
      version = 2;
      efiSupport = true;
      device = "nodev";

      useOSProber = true;
    };
  };


  networking.hostName = "nixos_jules_portable"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  # networking.useNetworkd = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # networking.interfaces.wlp0s20f0u4u2.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    colors = [
      "181818"
      "FA5A77"
      "2BE491"
      "FA946E"
      "6381EA"
      "CF8EF4"
      "89CCF7"
      "DCDCDC"
      "4C566A"
      "FA748D"
      "44EB9F"
      "FAA687"
      "7A92EA"
      "D8A6F4"
      "A1D5F7"
      "DCDCDC"
    ];
  };
  # services.udev.extraRules = "
  # RUN+=\"/nix/store/i15v8lm5ayyrib20iicng9igmnsjvgqm-system-path/bin/chgrp video /sys/class/backlight/intel_backlight/brightness\"
  # RUN+=\"/nix/store/i15v8lm5ayyrib20iicng9igmnsjvgqm-system-path/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness\"
  # ";
  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
      enable = true;


      # Enable the GNOME Desktop Environment.

      displayManager.gdm.enable = true;
      #displayManager.sddm.enable = true;

      displayManager.defaultSession = "none+i3";
      # displayManager.defaultSession = "none+bspwm";
      # displayManager.defaultSession = "sway";


      # desktopManager.gnome.enable = true;

      # desktopManager.xfce = {
      #   enable = true;
      #   enableXfwm = false;
      # };

      # windowManager.bspwm.enable = true;
      # windowManager.bspwm.package = "pkgs.bspwm-unstable";
      # windowManager.bspwm.configFile = "/home/user/dotfiles/common/bspwm/bspwmrc";
      # windowManager.bspwm.sxhkd.configFile= "/home/user/dotfiles/common/bspwm/sxhkdrc";

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };

      desktopManager.xterm.enable = false;
      libinput.enable = true;
  };

  services.gnome.gnome-keyring.enable = true; 


  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.fprintd.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups = {
    jules = {};
    nixos-config = {};
  };

  users.users.jules = {
    description = "Jules Lefebvre";

    isNormalUser = true;
    shell = pkgs.fish;

    createHome = true;
    home = "/home/jules";

    group = "jules";
    extraGroups = [ "users" "wheel" "nixos-config" "docker" "video" ]; # Enable ‘sudo’ for the user.
  };

  users.extraGroups.vboxusers.members = [ "jules" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim 
    pciutils

    man-pages
    man-pages-posix
    htop
    tree
    wget
    unzip
    zip

    docker-compose

    home-manager
  ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}


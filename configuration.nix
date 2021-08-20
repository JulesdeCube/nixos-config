# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  /*nixpkgs.overlays = [ (self: super: {
    discord = super.discord.overrideAttrs (_: {
      src = builtins.fetchTarball https://discord.com/api/download?platform=linux&format=tar.gz;
    });
  })]; */

  imports = [ 
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import "${builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-20.09.tar.gz}/nixos")
    ./users/jules.nix
  ];

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

  networking.hostName = "nixos_jules_desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    packages = [ pkgs.terminus_font ];
    # font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-v12n.psf.gz";
    earlySetup = true;
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


  hardware.nvidia.prime = {
    sync.enable = true;

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:0:0";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    videoDrivers = [ "nvidia" ];

    # Configure keymap in X11
    layout = "us";
    xkbOptions = "eurosign:e";

    xrandrHeads = [ { output = "HDMI-0"; primary = true; } "DVI-I-1" ];

    displayManager = {
      gdm.enable = true;
      sddm.autoNumlock = true;
      defaultSession = "none+i3";
      # defaultSession = "none+awesome";
      setupCommands = ''
        ${pkgs.xlibs.xrandr}/bin/xrandr --output HDMI-0 --left-of DVI-I-1
      '';
    };

    windowManager.i3 = {
      enable = true;
    };

    # windowManager.awesome = {
    #   enable = true;
    #   luaModules = with pkgs.luaPackages; [ luarocks luadbi-mysql ];
    # };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups = {
    jules = {};
    nixos-config = {};
  };

  users.users.jules = {
    description = "Jules Lefebvre";

    isNormalUser = true;
    useDefaultShell = true;

    createHome = true;
    home = "/home/jules";

    group = "jules";
    extraGroups = [ "users" "wheel" "nixos-config" "docker" ]; # Enable ‘sudo’ for the user.
  };

  environment.variables = {
    EDITOR = "vim";
    TERMINAL = "kitty";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    bat
    git
    screen
    wget 
    htop
    tree
    unzip
    zip
    pciutils


    man-pages 
    man-pages-posix 
    gcc
    gdb
    glibc
    valgrind
    gnumake

    rustup
    cargo

    # dotnet-netcore
    dotnet-sdk

    python39
    python39Packages.venvShellHook
    python39Packages.virtualenv
    python39Packages.ipykernel
    pipenv
    jupyter

    sqlite

    nodejs-16_x
    # nodePackages.npm

    jre8

    docker-compose

    firefox
    vlc
    kitty
    vscode
    discord
    slack
    minecraft
    typora

    polybarFull

    scrot
    xclip
    xorg.xrandr
    nitrogen
    picom
    asciinema
  ];

  documentation.dev.enable = true;

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
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  fonts = {
    enableDefaultFonts = true;

    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      nerdfonts
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts
      dina-font
      proggyfonts
      roboto
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "DejaVu Serif" ];
        emoji = [ "Noto Color Emoji" ];
        sansSerif = [ "Roboto" ];
        monospace = [ "Fira Code" ];
      };
    };
  };


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
  system.stateVersion = "20.09"; # Did you read the comment?

}


{ jdc-home-manager, home-manager, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    home-manager.nixosModules.default
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "
      experimental-features = nix-command flakes
    ";
  };

  programs.hyprland.enable = true;
  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
      };
    };

    binfmt.emulatedSystems = [ "aarch64-linux" ];

    kernel.sysctl."kernel.hostname" = "nixos-jules-portable.julesdecube.com";
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    colors = [
      "2D2A2E" # black/background
      "FF6188" # red
      "A9DC76" # green
      "FFD866" # yellow
      "FC9867" # blue
      "AB9DF2" # purple
      "78DCE8" # cyan
      "939293" # light grey
      "5B595C" # dark grey
      "FF84A2" # light red
      "C2E69E" # light green
      "FFE495" # light yellow
      "FDB896" # light blue
      "C8BFF7" # light purle
      "A3E7EF" # light cyan
      "FCFCFA" # white/forground
    ];
  };

  networking = {
    hostName = "nixos-jules-portable";
    domain = "julesdecube.com";

    wireless.enable = false;
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openconnect
        networkmanager-openvpn
      ];
    };

    firewall = {
      checkReversePath = true;
      enable = true;
    };
  };

  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
    };
  };

  systemd = {
    services.NetworkManager-wait-online.enable = false;
  };

  security.polkit.enable = true;

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];

      desktopManager.xterm.enable = false;
      displayManager.gdm.enable = true;

      xkb = {
        layout = "us";
        variant = "intl";
        options = "caps:escape";
      };
    };

    displayManager.sessionPackages = [
      (pkgs.stdenv.mkDerivation {
        passthru.providedSessions = [ "xservice-wayland" ];
        pname = "xservice-wayland";
        version = "1.0.0";
        src = ./.;

        phases = [ "installPhase" ];
        installPhase = ''
          mkdir -p $out/share/wayland-sessions
          cat > $out/share/wayland-sessions/xservice-wayland.desktop <<EOF
          [Desktop Entry]
          Name=Wayland-User
          Exec=/bin/sh -c "\$HOME/.xsession-wayland"
          Type=Application
          EOF
        '';
      })
    ];


    libinput.enable = true;

    fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-vfs0090;
      };
    };

    gnome.gnome-keyring.enable = true;

    udev = {
      enable = true;
      packages = [ pkgs.yubikey-personalization ];
    };
  };

  programs = {
    fish.enable = true;

    nm-applet = {
      enable = true;
      indicator = true;
    };

    ssh.startAgent = false;

    dconf.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  security = {
    pam.services = {
      login.fprintAuth = true;
      xscreensaver.fprintAuth = true;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    users.jules = "${jdc-home-manager}/home.nix";
  };

  users = {
    groups = {
      jules = { };
      nixos-config = { };
    };

    users = {
      jules = {
        description = "Jules Lefebvre";

        isNormalUser = true;
        shell = pkgs.fish;

        createHome = true;
        home = "/home/jules";

        group = "jules";
        extraGroups = [
          "users"
          "wheel"
          "nixos-config"
          "video"
          "audio"
          "networkmanager"
          "network"
          "uucp"
          "dialout"
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git
    vim

    tree
    wget
    unzip
    zip

    htop

    man-pages
    man-pages-posix
  ];

  system.stateVersion = "24.05";
}

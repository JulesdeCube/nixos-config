{ jdc-home-manager, home-manager, config, pkgs, ... }:
{
  # Extract configuration
  imports = [
    # Specific hardware configuration
    ./hardware-configuration.nix
    # Home-manager overlay
    home-manager.nixosModules.default
  ];

  # Allow unfree
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Enable flake
  nix = {
    extraOptions = "
      experimental-features = nix-command flakes
    ";
  };

  # Boot config
  boot = {
    # Enable grub
    loader = {
      # enable efi
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
    };

    # enable aarch64 arch emulation (for cross compilling)
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    # define hostname to fqdn
    kernel.sysctl."kernel.hostname" = config.networking.fqdnOrHostName;
  };

  # Set time zone
  time.timeZone = "Europe/Paris";
  # Set default location
  i18n.defaultLocale = "en_US.UTF-8";

  # TTY configuration
  console = {
    # Font
    font = "Lat2-Terminus16";
    # Keymap to qwerty
    keyMap = "us";
    # Colors
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

  # Network configuration
  networking = {
    # hostname
    hostName = "nixos-jules-portable";
    # domain
    domain = "julesdecube.com";

    # Use networkmanager for network configuration
    networkmanager = {
      # Enable networkmanager
      enable = true;
      # Add pluging for vpn
      plugins = with pkgs; [
        # Enable openvpn vpn
        networkmanager-openvpn
      ];
    };
  };

  hardware = {
    # Enable bluetooth
    bluetooth = {
      enable = true;
    };
    # Enable nvidia driver
    nvidia = {
      open = true;
    };
  };

  # systemd services configuration
  systemd = {
    # Services ovewrite
    services = {
      # Disable network manager wait online
      # see https://github.com/NixOS/nixpkgs/issues/180175
      # TODO remove when fix
      NetworkManager-wait-online.enable = false;
    };
  };


  # Services
  services = {
    # GnuPG yubikey
    pcscd = {
      enable = true;
    };
    # Display manager
    xserver = {
      # Enable graphical interface
      enable = true;
      # Use Nvidia driver
      videoDrivers = [ "nvidia" ];

      # Disable xterm
      desktopManager.xterm.enable = false;
      # Use gdm as manager
      displayManager.gdm.enable = true;

      # Configure  keyboard
      xkb = {
        # Use QWERTY keyboard
        layout = "us";
        # Use international variante
        variant = "intl";
        # Switch capslock to escape key
        options = "caps:escape";
      };
    };

    # Wayland input
    libinput.enable = true;

    # Custom session package to user specify Wayland
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

    # Enable gnome keyring for secret management
    gnome.gnome-keyring.enable = true;

    # Enable finger print
    fprintd = {
      enable = true;
      # Touch OEM Drivers
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-vfs0090;
      };
    };

    # Enable udev for yubikey
    udev = {
      enable = true;
      packages = [ pkgs.yubikey-personalization ];
    };
  };

  # Program configuration
  programs = {
    # Enable fish
    fish.enable = true;

    # Enable network manager applet
    nm-applet = {
      enable = true;
      indicator = true;
    };

    # Enable gpg-agent
    gnupg.agent = {
      enable = true;
      # Enable SSH via GPG
      enableSSHSupport = true;
    };
  };

  # Security
  security = {
    # Enable polkit
    polkit.enable = true;
  };

  # Enable user configuration
  home-manager = {
    # Use global packages
    useGlobalPkgs = true;
    # Main user configuration
    users.jules = { ... }: {
      imports = [
        # Use configuration from jdc-home-manager flake
        jdc-home-manager.homeManagerModules.x86_64-linux.default
      ];
      # nix home manager internal state
      home.stateVersion = "22.11";
    };
  };

  users = {
    groups = {
      jules = { };
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

  # System wide packages
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

  # Nix internal db state version
  system.stateVersion = "24.05";
}

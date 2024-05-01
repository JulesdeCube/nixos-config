{ jdc-home-manager,  home-manager, config, lib, pkgs, ... }:
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
      checkReversePath = false;
      enable = false;
    };
  };

  hardware ={
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

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    lxd.enable = true;
  };

  security.polkit.enable = true;

  services = {
    spice-vdagentd.enable = true;

    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];

      displayManager = {
        gdm = {
          enable = true;
          wayland = false;
        };
        defaultSession = "none+i3";
      };
      desktopManager.xterm.enable = false;

      libinput.enable = true;

      xkb = {
        layout = "us";
        variant = "intl";
        options = "caps:escape";
      };
    };

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
    pki.certificateFiles = [
      (builtins.fetchurl {
        url = "https://vault.srs.epita.fr/v1/pki/ca/pem";
        sha256 = "2275677c71e237c7d11a49997193018138884b1c6a9513f2eff4ce9d4545fd04";
        })
    ];
  };

  home-manager.users = {
    jules = "${jdc-home-manager}/home.nix";
  };

  users = {
    groups = {
      jules = {};
      nixos-config = {};
    };

    users = {
      root = {
        autoSubUidGidRange = false;

        subGidRanges = [{
          count = 655360;
          startGid = 1000000;
        }];
        subUidRanges = [{
          count = 655360;
          startUid = 1000000;
        }];
      };
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
          "docker"
          "video"
          "audio"
          "networkmanager"
          "network"
          "uucp"
          "dialout"
          "libvirtd"
          "lxd"
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

    arandr
  ];

  system.stateVersion = "24.05";
}

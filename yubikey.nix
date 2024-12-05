{ pkgs
, modulesPath
, ...
}:
let
  gpg-agent-conf = pkgs.writeText "gpg-agent.conf" ''
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
  '';
in
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  ## Image overrides.

  isoImage.isoBaseName = pkgs.lib.mkForce "nixos-yubikey";

  # Always copytoram so that, if the image is booted from, e.g., a
  # USB stick, nothing is mistakenly written to persistent storage.

  boot.kernelParams = [ "copytoram" ];

  ## Required packages and services.
  #
  # ref: https://rzetterberg.github.io/yubikey-gpg-nixos.html
  environment.systemPackages = with pkgs; [
    cfssl
    cryptsetup
    diceware
    ent
    git
    gitAndTools.git-extras
    gnupg
    paperkey
    parted
    pcsclite
    pcsctools
    pgpdump
    pinentry-curses
    pwgen
    yubikey-manager
    yubikey-personalization
  ];
  services.udev.packages = [
    pkgs.yubikey-personalization
  ];
  services.pcscd.enable = true;


  ## Make sure networking is disabled in every way possible.

  boot.initrd.network.enable = false;
  networking.dhcpcd.enable = false;
  networking.dhcpcd.allowInterfaces = [ ];
  networking.firewall.enable = true;
  networking.useDHCP = false;
  networking.useNetworkd = false;
  networking.wireless.enable = false;


  # Most of the following config is thanks to Graham Christensen,
  # from:
  # https://github.com/grahamc/network/blob/1d73f673b05a7f976d82ae0e0e61a65d045b3704/modules/standard/default.nix#L56
  nix = {
    useSandbox = true;
    nixPath = [
      # Copy the channel version from the deploy host to the target
      "nixpkgs=/run/current-system/nixpkgs"
    ];
  };
  system.extraSystemBuilderCmds = ''
    ln -sv ${pkgs.path} $out/nixpkgs
  '';
  environment.etc.host-nix-channel.source = pkgs.path;


  ## Secure defaults.

  boot.cleanTmpDir = true;
  boot.kernel.sysctl = {
    "kernel.unprivileged_bpf_disabled" = 1;
  };


  ## Set up the shell for making keys.

  environment.interactiveShellInit = ''
    unset HISTFILE
    export GNUPGHOME=/run/user/$(id -u)/gnupg
    [ -d $GNUPGHOME ] || install -m 0700 -d $GNUPGHOME
    cp ${gpg-agent-conf}  $GNUPGHOME/gpg-agent.conf
    echo "\$GNUPGHOME is $GNUPGHOME"
  '';
}

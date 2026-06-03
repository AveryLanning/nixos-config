# Edit this configuration file to define what should be installed on

# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-7fd1c891-8a9b-48f6-8107-28f3f524c5d5".device = "/dev/disk/by-uuid/7fd1c891-8a9b-48f6-8107-28f3f524c5d5";
  networking.hostName = "averyNix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  #Configure Colemak keymap in TTY
  console.keyMap = "colemak";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.avery = {
    isNormalUser = true;
    description = "Avery Lanning";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.nushell;
    packages = with pkgs; [];
  };

  #The xmonad desktop
  services.xserver = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ''
        import XMonad
        import XMonad.Hooks.ManageDocks
        import XMonad.Hooks.DynamicLog
        import System.Exit

        main :: IO ()
        main = xmonad $ docks $ def
          { terminal = "ghostty"
          , startupHook = spawn "polybar main"
          , manageHook = manageDocks <+> manageHook def
          , layoutHook = avoidStruts $ layoutHook def
          }
      '';
    };
  };

 # enableContribAndExtras = true;
   # config = ''
   #   import XMonad
   #   main = xmonad $ def
   #     { terminal = "rio"}
   # '';
#  };

  # Enable unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    haskellPackages.xmonad
    haskellPackages.xmonad-contrib
    polybar #status bar
    #xmobar #status bar
    rofi #launcher
    dmenu #launcher
    ghostty #terminal emulator
    #rio
    kakoune
    home-manager
    nushell
    notmuch
    yazi
    fd
    git
    unzip
    qutebrowser
    gammastep
    acpi
    sioyek
    zotero
    spotify
    weather
    pinentry-tty
    pass
    himalaya
    zk
    e2fsprogs
    dosfstools
    exfatprogs
    ntfs3g
    f3
    xclip
    xdotool
    keychain
    xorg.xev
    libreoffice
];

  environment.variables = {
    EDITOR = "kak";
    VISUAL = "kak";
    SUDO_EDITOR = "kak";
  };

  #Nice helpful features that are increasily needed
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;


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
  system.stateVersion = "25.11"; # Did you read the comment?

  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR VISUAL SUDO_EDITOR"
    Defaults editor = /run/current-system/sw/bin/kak
'';
}

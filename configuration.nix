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
    extraGroups = [ "networkmanager" "wheel" "video" ];
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
        import Data.Map (fromList)
        import Graphics.X11.ExtraTypes.XF86

        main :: IO ()
        main = xmonad $ docks $ def
          { terminal = "ghostty"
          , startupHook = spawn "polybar main"
          >> spawn "gammastep -l 37.7:-97.3 -m randr"
          >> spawn "systemctl --user start gpg-agent-ssh.socket"
          , manageHook = manageDocks <+> manageHook def
          , layoutHook = avoidStruts $ layoutHook def
          , keys = \c -> keys def c <> myKeys c
          }

        myKeys conf = fromList
          [  ((mod4Mask, xK_p), spawn "rofi -show drun")
          , ((mod4Mask .|. shiftMask, xK_p), spawn "rofi -show window")
			    , ((mod4Mask, xK_Print), spawn "maim ~/documents/pictures/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png")
          , ((mod4Mask .|. shiftMask, xK_Print), spawn "maim -s /tmp/screenshot.png && satty --filename /tmp/screenshot.png --output-filename ~/documents/pictures/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png")
          , ((mod4Mask .|. controlMask, xK_Print), spawn "maim -s | xclip -selection clipboard -t image/png")
  			  , ((0, xF86XK_MonBrightnessUp), spawn "brightnessctl set +10%")
					, ((0, xF86XK_MonBrightnessDown), spawn "brightnessctl set 10%-")
					, ((0, xF86XK_AudioRaiseVolume), spawn "pamixer --increase 5")
          , ((0, xF86XK_AudioLowerVolume), spawn "pamixer --decrease 5")
          , ((0, xF86XK_AudioMute), spawn "pamixer --toggle-mute")
          ]
      '';
    };
  };

  services.syncthing =  {
    enable = true;
    user = "avery";
    dataDir = "/home/avery/syncthing";
    configDir = "/home/avery/.config/syncthing";
  };

 # enableContribAndExtras = true;
   # config = ''
   #   import XMonad
   #   main = xmonad $ def
   #     { terminal = "rio"}
   # '';
#  };

  nixpkgs.overlays = [
    (final: prev: {
      papis = prev.python3Packages.toPythonApplication (
        prev.python3Packages.papis.overridePythonAttrs (old: {
          propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [
            prev.python3Packages.packaging
            prev.python3Packages.pypdf
          ];
        })
      );
    })
  ];

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
    rofi #launcher
    ghostty #terminal emulator
    kakoune
    home-manager
    nushell
    notmuch
    yazi
    fd
    git
    unzip
    qutebrowser
    nyxt
    gammastep #Automatically shifts the screen red at night
    acpi
    sioyek
    spotify
    wego #Weather
    pinentry-tty
    pinentry-gtk2 #Fixes a bug involving availability to open gpg after display manager restarts
    pass #Password Storage
    himalaya #Emai
    zk # Linked Notes Manager
    #File formatting tools
    e2fsprogs
    dosfstools
    exfatprogs
    ntfs3g
    f3 #Used to test if flash drive is a scam
    
    xclip
    syncthing
    libreoffice
    termdown
    fzf
    papis
    nsxiv #Image Viewer
    maim  #Screenshots
    satty #Basic markup for screenshots
    brightnessctl
    bottom #System monitor
    mpv #Keyboard video player
    #pandoc #useful document converter to consider
    pamixer #Audio control
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

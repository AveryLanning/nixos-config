{ config, pkgs, ... }:
{
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

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.avery = {
    isNormalUser = true;
    description = "Avery Lanning";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.nushell;
    packages = with pkgs; [];
  };

  services.syncthing = {
    enable = true;
    user = "avery";
    dataDir = "/home/avery/syncthing";
    configDir = "/home/avery/.config/syncthing";
  };

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

  #Enabling so I can turn on System-wide GNOME/libadwaita dark mode
  programs.dconf.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  # Enable unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.enableAllTerminfo = true;

  # Packages shared by every machine
  environment.systemPackages = with pkgs; [
    ghostty #terminal emulator
    kakoune
    kakoune-lsp
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
    sioyek
    spotify
    wego #Weather
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
    bottom #System monitor
    mpv #Keyboard video player
    #pandoc #useful document converter to consider
    pamixer #Audio control
    ripgrep #Faster grep
    jq #JSON tool
    bat #cat but with syntax highlighting
    calibre #Ebook library and reader
    ladybugdb
    rnote
    freecad
    f3d #Lightweight CAD viewer
    chafa #terminal image viewer
    visidata
    postgresql #Database
    firefox #Many sites like to block the modal browsers
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

  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR VISUAL SUDO_EDITOR"
    Defaults editor = /run/current-system/sw/bin/kak
  '';
}

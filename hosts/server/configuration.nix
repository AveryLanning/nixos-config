{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common/configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # LUKS: if the tower's disk is encrypted, copy its boot.initrd.luks.devices
  # line from the tower's existing /etc/nixos/configuration.nix here.

  networking.hostName = "averyServer";

  # Always-on server: never sleep, even if a DE power setting tries.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # --- Desktop: KDE Plasma (controller-friendly gaming) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # --- Audio ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Gaming ---
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  # --- Nvidia proprietary drivers (3070 Ti) ---
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false; # proprietary kernel module
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # needed for Steam / 32-bit games
  };

  # --- SSH (headless management from the laptop) ---
  services.openssh = {
    enable = true;
    # Flip to false once your key is on the tower:
    #   ssh-copy-id or paste ~/.ssh/gpg_auth.pub into ~/.ssh/authorized_keys
    settings.PasswordAuthentication = true;
  };

  # --- PostgreSQL (food tracker + future data) ---
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "foodtracker" ];
    ensureUsers = [{
      name = "avery";
      ensureDBOwnership = true;
    }];
    # Local-only for now. LAN access for the Pi/laptop clients comes later
    # (listen_addresses + pg_hba entries).
  };

  # --- Jellyfin (music/media) ---
  services.jellyfin = {
    enable = true;
    user = "avery"; # so it can read media in /home/avery
    openFirewall = true; # opens 8096 (http) + discovery ports
  };

  # --- Calibre-web (books) ---
  services.calibre-web = {
    enable = true;
    listen.ip = "0.0.0.0";
    listen.port = 8083;
    options = {
      enableBookUploading = true;
      # Point at a real Calibre library folder once it exists:
      calibreLibrary = "/home/avery/books";
    };
  };

  # --- Firewall ---
  # 22 opened by openssh automatically, 8096 by jellyfin.openFirewall
  networking.firewall.allowedTCPPorts = [
    8083 # calibre-web
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data were taken.
  # IMPORTANT: set this to whatever the tower's EXISTING configuration.nix
  # says before rebuilding. Do NOT invent a new value.
  system.stateVersion = "25.11"; # <-- verify against the tower!
}

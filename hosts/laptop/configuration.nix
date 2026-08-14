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

  boot.initrd.luks.devices."luks-7fd1c891-8a9b-48f6-8107-28f3f524c5d5".device = "/dev/disk/by-uuid/7fd1c891-8a9b-48f6-8107-28f3f524c5d5";
  networking.hostName = "averyNix"; # Define your hostname.

	#This fixes the race condition that randomly breaks my mouse on bootup
  systemd.services.display-manager.after = [ "systemd-udev-settle.service" ];
  systemd.services.display-manager.wants = [ "systemd-udev-settle.service" ];

  #BIOS - enable this and run the commands below to update the BIOS
  services.fwupd.enable = false;
    #fwupdmgr refresh
    #fwupdmgr get-updates
    #fwupdmgr update

  services.logind.settings.Login = {
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
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
          , modMask = mod4Mask
          , startupHook = spawn "polybar main"
          >> spawn "systemctl --user start gpg-agent-ssh.socket"
          , manageHook = manageDocks <+> manageHook def
          , layoutHook = avoidStruts $ layoutHook def
          , keys = \c -> myKeys c <> keys def c
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

  services.acpid = {
    enable = true;
    handlers = {
      lid = {
        event = "button/lid.*";
        action = ''
          #!/bin/sh
          export DISPLAY=:0
          export XAUTHORITY=/home/avery/.Xauthority

          LID_STATE=$(cat /proc/acpi/button/lid/LID0/state)

          if echo "$LID_STATE" | grep -q "closed"; then
            EXTERNAL=$(su avery -c 'DISPLAY=:0 XAUTHORITY=/home/avery/.Xauthority xrandr' | grep " connected" | grep -v "eDP")
            if [ -n "$EXTERNAL" ]; then
              su avery -c 'DISPLAY=:0 XAUTHORITY=/home/avery/.Xauthority xrandr --output eDP-1 --off'
              sleep 0.5
              pkill -u avery polybar
              sleep 0.2
              su avery -c 'DISPLAY=:0 XAUTHORITY=/home/avery/.Xauthority polybar main &'
            fi
          else
            su avery -c 'DISPLAY=:0 XAUTHORITY=/home/avery/.Xauthority xrandr --output eDP-1 --auto'
            sleep 0.5
            pkill -u avery polybar
            sleep 0.2
            su avery -c 'DISPLAY=:0 XAUTHORITY=/home/avery/.Xauthority polybar main &'
          fi
        '';
      };
    };
  };


	services.xserver.config = ''
  Section "InputClass"
    Identifier "Ignore touchscreen as pointer"
    MatchProduct "ILIT2901"
    MatchIsTouchscreen "true"
    Option "SendCoreEvents" "false"
  EndSection
	'';

  # Laptop-only packages (xmonad stack + laptop hardware tools)
  environment.systemPackages = with pkgs; [
    haskellPackages.xmonad
    haskellPackages.xmonad-contrib
    polybar #status bar
    rofi #launcher
    acpi
    brightnessctl
    maim  #Screenshots
    satty #Basic markup for screenshots
    moonlight-qt
    xev #Useful for keyboard troubleshooting
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Do not change it after install.
  system.stateVersion = "25.11"; # Did you read the comment?
}

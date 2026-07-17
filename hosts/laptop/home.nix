{ config, pkgs, ... }:
{
  imports = [
    ../../common/home.nix
  ];

  programs.autorandr = {
    enable = true;
    hooks = {
      postswitch = {
        "restart-xmonad" = "xmonad --restart";
      };
    };
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar;
    script = ''
      ${pkgs.bash}/bin/bash -c "polybar main &"
    '';

    settings = {
      "bar/main" = {
        bottom = false;
        width = "100%";
        height = 24;
        background = "#000000";
        foreground = "#f8f8f2";
        font-0 = "monospace:size=10";
        modules-center = "date";
        modules-right = "volume email battery";
        enable-ipc = true;
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%a %b %d";
        time = "%H:%M:%S";
        label = "%date% | %time%";
      };

      "module/battery" = {
        type = "internal/battery";
        battery = "BAT1";
        adapter = "AC";
        full-at = 98;
        label-charging = " | c%percentage%%";
        label-discharging = " | d%percentage%%";
        label-full = " | Full";
      };

      "module/volume" = {
        type = "custom/script";
        exec = "${pkgs.bash}/bin/bash -c 'pamixer --get-volume-human'";
        interval = 2;
        label = "Vol:%output% | ";
      };

      "module/email" = {
        type = "custom/script";
        exec = "${pkgs.writeShellScript "polybar-mail" ''
          himalaya envelope list 2>/dev/null | grep -c '*' || echo 0
        ''}";
        interval = 300;
        label = "Mail:%output%";
      };
    };
  };
}

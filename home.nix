{ config, pkgs, ... }:
{
  imports = [
    ./home/kakoune.nix
  ];

  home.username = "avery";
  home.homeDirectory = "/home/avery";

  home.stateVersion = "25.11";

  home.sessionVariables = {
    EDITOR = "kak";
    VISUAL = "kak";
    SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
  };

  home.file.".ssh/gpg_auth.pub" = {
    text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC89vKRl6c3UxGvyhmv1FazcZ5FmuCEohnma5n4Dr0UB openpgp:0xC09C9072\n";
  };

  programs.bash.enable = true;

  programs.nushell = {
    enable = true;

    extraEnv = ''
       gpg-connect-agent updatestartuptty /bye out+err> /dev/null
    '';

    extraConfig = ''
      def weather-haven [] {
        wego -owm-api-key (pass show api&ai/OpenWeather) -f json Haven,Kansas,US| from json
      }
      def weat [location: string = "Wichita,US"] {
        wego -owm-api-key (pass show api&ai/OpenWeather) -l $location -f json | from json
      }
      $env.config = ($env.config | upsert edit_mode "vi")
      $env.config = ($env.config | upsert keybindings (
        ($env.config.keybindings) ++ [
          { name: vi_down,         modifier: none, keycode: char_n, mode: [vi_normal], event: { send: Down              } }
          { name: vi_up,           modifier: none, keycode: char_e, mode: [vi_normal], event: { send: Up                } }
          { name: vi_left,         modifier: none, keycode: char_h, mode: [vi_normal], event: { send: Left              } }
          { name: vi_right,        modifier: none, keycode: char_i, mode: [vi_normal], event: { send: Right             } }
          { name: vi_insert,       modifier: none, keycode: char_u, mode: [vi_normal], event: { send: ViChangeMode, mode: "insert" } }
          { name: vi_insert_bol,   modifier: none, keycode: char_U, mode: [vi_normal], event: { send: ViChangeMode, mode: "insert" } }
          { name: vi_delete_char,  modifier: none, keycode: char_s, mode: [vi_normal], event: { edit: Delete            } }
          { name: vi_word_right,   modifier: none, keycode: char_f, mode: [vi_normal], event: { edit: MoveWordRightStart } }
          { name: vi_word_left,    modifier: none, keycode: char_b, mode: [vi_normal], event: { edit: MoveWordLeft      } }
          { name: vi_search,       modifier: none, keycode: char_k, mode: [vi_normal], event: { send: SearchHistory     } }
          { name: vi_end_of_line,  modifier: none, keycode: char_l, mode: [vi_normal], event: { edit: MoveToLineEnd     } }
          { name: vi_bol,          modifier: none, keycode: char_0, mode: [vi_normal], event: { edit: MoveToLineStart   } }
         ]
      ))
    '';
  };

  programs.git = {
    enable = true;
      
    #settings.user.name = "AveryLanning";
    #settings.user.email = "avery@lanning.org";

    settings = {
        init.defaultBranch = "main";
        user.name = "AveryLanning";
        user.email = "avery@lanning.org";

    };
  };

  #programs.yazi = {
  #  enable = true;
  #  enableNushellIntegration = true;
  #
  #  keymap = {
  #    manager = {
  #      append_keymap = [
  #        {
  #          on = [ "z" ];
  #          run = "quit";
  #          desc = "quit";
  #        }
  #      ];
  #    };
  #  };
  #};

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
    enableSshSupport = true;
    defaultCacheTtl = 36000;
    defaultCacheTtlSsh = 36000;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        identitiesOnly = true;
  			identityFile = "~/.ssh/gpg_auth.pub";
				extraOptions = {
          IdentityAgent = "/run/user/1000/gnupg/S.gpg-agent.ssh"; #Hardcoded, but could change on another machine
        };
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
        label-full = "Full";
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

  #himalaya email client
  home.file.".config/himalaya/config.toml".text = ''
    [accounts.Porkbun]
    default = true
    email = "avery@lanning.org"
    display-name = "Avery Lanning"
    downloads-dir = "/home/avery/Downloads"
    backend.type = "imap"
    backend.host = "imap.porkbun.com"
    backend.port = 993
    backend.login = "avery@lanning.org"
    backend.encryption.type = "tls"
    backend.auth.type = "password"
    backend.auth.command = "pass show email/porkbun"
    message.send.backend.type = "smtp"
    message.send.backend.host = "smtp.lanning.org"
    message.send.backend.port = 465
    message.send.backend.login = "avery@lanning.org"
    message.send.backend.encryption.type = "tls"
    message.send.backend.auth.type = "password"
    message.send.backend.auth.command = "pass show email/porkbun"
    [accounts.Porkbun.folder.aliases]
    email = "avery@lanning.org"
    inbox = "INBOX"
    sent = "INBOX.Sent"
    drafts = "INBOX.Drafts"
    trash = "INBOX.Trash"
  '';

	#ghostty terminal emulator
  home.file.".config/ghostty/config".text = ''
    font-family = monospace
    font-size = 13
    background = #000000
    foreground = #f8f8f2
    shell-integration = detect
    shell-integration-features = no-cursor
  '';

#  xresources.properties = {
#    "XTerm*background" = "#000000";
#    "XTerm*foreground" = "#f8f8f2";
#
#    "XTerm*cursorColor" = "#ff5555";

#    "XTerm*color0"  = "#000000";
#    "XTerm*color1"  = "#ff5555";
#    "XTerm*color2"  = "#50fa7b";
#    "XTerm*color3"  = "#f1fa8c";
#    "XTerm*color4"  = "#bd93f9";
#    "XTerm*color5"  = "#ff79c6";
#    "XTerm*color6"  = "#8be9fd";
#    "XTerm*color7"  = "#bbbbbb";

#    "XTerm*faceName" = "monospace";
#    "XTerm*faceSize" = 12;
#  };

  home.packages = with pkgs; [
  ];
}

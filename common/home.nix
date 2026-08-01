{ config, pkgs, ... }:
{
  imports = [
    ./kakoune.nix
    ./zk.nix
    ./papis.nix
    ./nyxt.nix
    ./visidata.nix
    ./yazi.nix
    ./sioyek.nix
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
       $env.FZF_DEFAULT_OPTS = "--bind=ctrl-n:down,ctrl-e:up"
       $env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/bin")
       gpg-connect-agent updatestartuptty /bye out+err> /dev/null
    '';

    extraConfig = ''
      def calibre [...args] {
        with-env {LD_LIBRARY_PATH: $"(nix-build --no-out-link '<nixpkgs>' -A openssl.out)/lib"} {
          ^calibre ...args
        }
      }

      def zke [] {
        with-env {SHELL: "${pkgs.bash}/bin/bash"} {
          zk edit -i
        }
      }

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

    settings = {
        init.defaultBranch = "main";
        user.name = "AveryLanning";
        user.email = "avery@lanning.org";

    };
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gtk2;
    enableSshSupport = true;
    defaultCacheTtl = 36000;
    defaultCacheTtlSsh = 36000;
    maxCacheTtl = 36000;
    maxCacheTtlSsh = 36000;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        IdentityAgent = "/run/user/1000/gnupg/S.gpg-agent.ssh"; #Hardcoded, but could change on another machine
      };
    };
  };

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 37.7;   # your approximate latitude
    longitude = -97.3; # your approximate longitude (Wichita, KS)

    temperature = {
      day = 5500;
      night = 1500;
    };

    settings.general = {
      brightness-day = 1.0;
      brightness-night = 0.4;
    };
  };

  #Sioyek - home manager doesn't seem do toggle dark mode correctly
  home.file.".config/sioyek/prefs_user.config".text = ''
    startup_commands toggle_dark_mode
  '';

  #himalaya email client
  home.file.".config/himalaya/config.toml".text = ''
    [accounts.Porkbun]
    default = true
    email = "avery@lanning.org"
    display-name = "Avery Lanning"
    downloads-dir = "/home/avery/downloads"
    backend.type = "imap"
    backend.host = "imap.porkbun.com"
    backend.port = 993
    backend.login = "avery@lanning.org"
    backend.encryption.type = "tls"
    backend.auth.type = "password"
    backend.auth.command = "pass show email_Web/porkbunEmail"
    message.send.backend.type = "smtp"
    message.send.backend.host = "smtp.porkbun.com"
    message.send.backend.port = 465
    message.send.backend.login = "avery@lanning.org"
    message.send.backend.encryption.type = "tls"
    message.send.backend.auth.type = "password"
    message.send.backend.auth.command = "pass show email_Web/porkbunEmail"
    envelope.list.page-size = 50
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

  #Kakoune seems to have xterm hardcoded - this makes the coloring match ghostty
  xresources.properties = {
    "XTerm*background" = "#000000";
    "XTerm*foreground" = "#f8f8f2";
  };

  #System-wide GNOME/libadwaita dark mode setting
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.packages = with pkgs; [
  ];
}

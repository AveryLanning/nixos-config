{ config, pkgs, ... }:
{
  xdg.configFile."papis/config".text = ''
    [settings]
    add-fetch-citations = True
    auto-doctor = True

    [tui]
    editmode = vi
    # Ctrl-N (down) already lands on the physical "j" key under Colemak, matching
    # vim's j=down muscle memory. Ctrl-P (papis's hardcoded "up" alt) does NOT --
    # under Colemak, Ctrl-P sits at qwerty's "r" key. Override move_up_key so
    # Ctrl-E (physically the qwerty "k" key under Colemak) is up instead, keeping
    # the down/up pair on the same physical keys as every other app.
    move_down_key = c-n
    move_up_key = c-e
  '';
}

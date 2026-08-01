{ config, pkgs, ... }:
{
  xdg.configFile."papis/config".text = ''
    [settings]
    default-library = research
    add-fetch-citations = True
    auto-doctor = True
    add-confirm = True

    [research]
    dir = /home/avery/research
    opentool = sioyek
    editor = kak
    use-git = true
    notes-name = notes.md
    database-backend = papis
    bibtex-unicode = True
    ref-format = {doc[title]:.15} {doc[author]:.6} {doc[year]}
    multiple-authors-format = {au[family]}, {au[given]}
    citations-file-name = citations.json
    add-folder-name = {doc[ref]}

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

{ pkgs, ... }:
let
  papis-cite = pkgs.writeShellScriptBin "papis-cite" ''
    set -euo pipefail
    session="$1"
    client="$2"
    ref=$(${pkgs.papis}/bin/papis list --format '{doc[ref]}')
    if [ -z "$ref" ]; then
      exit 0
    fi
    echo "evaluate-commands -client '$client' -- 'execute-keys \"<esc>i\\cite{$ref}<esc>\"'" | ${pkgs.kakoune}/bin/kak -p "$session"
    # keep the bibliography in sync with the library on every citation
    ${pkgs.papis}/bin/papis export -a -f bibtex -b -o /home/avery/research/library.bib
  '';
  papis-note = pkgs.writeShellScriptBin "papis-note" ''
    set -euo pipefail
    session="$1"
    client="$2"
    picked=$(${pkgs.papis}/bin/papis list --format '{doc[ref]}|||{doc[title]}')
    if [ -z "$picked" ]; then
      exit 0
    fi
    ref="''${picked%%|||*}"
    title="''${picked#*|||}"

    notes_dir="$HOME/notes/papers"
    mkdir -p "$notes_dir"
    note_path="$notes_dir/$ref.md"

    if [ ! -f "$note_path" ]; then
      cat > "$note_path" << EOF
---
title: $title
tags: [paper]
papis_ref: $ref
---
# $title

Cite key: \cite{$ref}
EOF
    fi

    echo "evaluate-commands -client '$client' -- 'edit \"$note_path\"'" | ${pkgs.kakoune}/bin/kak -p "$session"
  '';
  papis-open-source = pkgs.writeShellScriptBin "papis-open-source" ''
    set -euo pipefail
    buffile="$1"
    ref=$(${pkgs.gnugrep}/bin/grep -m1 '^papis_ref:' "$buffile" | sed 's/^papis_ref: *//')
    if [ -z "$ref" ]; then
      echo "papis-open-source: no papis_ref in '$buffile'" >&2
      exit 1
    fi
    ${pkgs.papis}/bin/papis open -a "ref:$ref"
  '';
in
{
  home.packages = [ papis-cite papis-note papis-open-source ];

	 xdg.configFile."kak-lsp/kak-lsp.toml".text = ''
    [language.rust]
    filetypes = ["rust"]
    roots = ["Cargo.toml"]
    command = "rust-analyzer"

    [language.rust.settings.rust-analyzer]
    cargo.allFeatures = true
    cargo.buildScripts.enable = true
    checkOnSave.command = "clippy"
    procMacro.enable = true
  '';

	programs.kakoune = {
    enable = true;
    config = {
      ui.enableMouse = false; #Keeps me from accidently moving around because I brushed the mousepad
      numberLines = { #Error messages provide line numbers, so this helps debug
        enable = true;
        relative = false;
        highlightCursor = true;
      };
    };
    extraConfig = ''
      # Load kakoune-lsp
      eval %sh{kak-lsp --kakoune -s $kak_session}
      # Start the server for Markdown buffers
      hook global WinSetOption filetype=markdown %{ lsp-enable-window }
      # Point Markdown at zk's language server
      hook global BufSetOption filetype=markdown %{
          set-option buffer lsp_servers %{
              [zk]
              args       = ["lsp"]
              root_globs = [".zk"]
          }
      }

      # Rust: enable LSP, inlay hints, hover, format on save
      hook global WinSetOption filetype=rust %{
          lsp-enable-window
          lsp-inlay-hints-enable window
          lsp-auto-hover-enable
      }
      hook global BufWritePre .*\.rs %{
          lsp-formatting-sync
      }
      # Start the server for Markdown buffers
      hook global WinSetOption filetype=markdown %{ lsp-enable-window }
      # Point Markdown at zk's language server
      hook global BufSetOption filetype=markdown %{
          set-option buffer lsp_servers %{
              [zk]
              args       = ["lsp"]
              root_globs = [".zk"]
          }
      }
      #Split off selection into a new note in zk
      define-command zk-mitosis -docstring "Split selection into a new note, replace with a link" %{
        prompt 'Note title: ' %{
            execute-keys -draft "|ZK_TITLE='%val{text}' zk-mitosis<ret>"
        }
			}
      #Open rnote, let me draw in it and link back to the drawing at this location
      define-command zk-sketch -docstring "Insert a hand-drawn diagram via rnote" %{
		 		nop %sh{
      		setsid zk-sketch "$kak_buffile" "$kak_session" "$kak_client" > /dev/null 2>&1 < /dev/null &
   			}
		  }
      #Open my rnote files, or the images, in kakoune
      define-command zk-open-attachment -docstring "Open the selected attachment with its associated app" %{
          nop %sh{
              path="$HOME/notes/$kak_selection"
              case "$path" in
                  *.rnote)
                      setsid rnote "$path" > /dev/null 2>&1 < /dev/null &
                      ;;
                  *)
                      setsid xdg-open "$path" > /dev/null 2>&1 < /dev/null &
                      ;;
              esac
          }
      }
      #Open a papis picker, insert \cite{ref} for the paper picked at cursor
      define-command papis-cite -docstring "Pick a paper from papis and insert \cite{ref}" %{
          terminal papis-cite %val{session} %val{client}
      }
      #Open a papis picker, open (or create) that paper's note in zk
      define-command papis-note -docstring "Pick a paper from papis and open/create its zk note" %{
          terminal papis-note %val{session} %val{client}
      }
      #From a paper's zk note, open its source PDF via papis (looks up papis_ref
      #in frontmatter, so it survives papis folder renames)
      define-command papis-open-source -docstring "Open this note's paper in papis" %{
          nop %sh{
              setsid papis-open-source "$kak_buffile" > /dev/null 2>&1 < /dev/null &
          }
      }
      declare-user-mode zk
      map global normal <space> ': enter-user-mode zk<ret>' -docstring 'zk mode'
      map global zk n ': zk-mitosis<ret>' -docstring 'split selection into new note'
      map global zk f ': terminal zk-picker<ret>' -docstring 'zk: fuzzy find note'
      map global zk s ': zk-sketch<ret>' -docstring 'zk: insert rnote sketch'
      map global zk e ': zk-open-attachment<ret>' -docstring 'zk: open attachment under selection'
      map global zk c ': papis-cite<ret>' -docstring 'zk: insert citation from papis'
      map global zk p ': papis-note<ret>' -docstring 'zk: open/create paper note in zk'
      map global zk o ': papis-open-source<ret>' -docstring 'zk: open this paper via papis'
      # LaTeX-only: dedicated shortcut for citing, scoped via hook so it only
      # exists in .tex buffers
      hook global WinSetOption filetype=latex %{
          map buffer normal <a-c> ': papis-cite<ret>' -docstring 'insert citation from papis'
      }
      # Recent versions stopped adding these by default — add them back
      map global goto s '<esc>:lsp-definition<ret>'      -docstring 'LSP definition'
      map global goto p '<esc>:lsp-references<ret>'       -docstring 'LSP references'
      # Optional: restore the breadcrumb in the modeline
      set-option global modelinefmt "%opt{lsp_modeline} %opt{modelinefmt}"
      set-option global tabstop 2
      set-option global indentwidth 2
      set-option global eolformat lf
      #Remapping so all command keys remain in their original position
      #Something between Nushell and XMonad appear to set backspace to ^H, which kakoune is not recognizing
      map global insert <c-h> '<backspace>'
      #row 1
      #map global normal q q # unchanged in colemak
      #map global normal w w # unchanged
      map global normal f e
      map global normal p r
      map global normal g t
      map global normal j y
      map global normal l u
      map global normal u i  #insert key
      map global normal y o
      map global normal ';' p
      #row 2 (home row)
      #map global normal a a
      map global normal r s
      map global normal s d
      map global normal t f
      map global normal d g 
      
      #map global normal h h 
      map global normal n j
      map global normal e k
      map global normal i l
      map global normal o ';' #Needs quotes so ; is not a command separator
      #row 3
      #map global normal z z
      #map global normal x x
      #map global normal c c
      #map global normal v v
      #map global normal b b
      map global normal k n
      #map global normal m m
     
      #Now Uppercase 
      #row 1
      #map global normal q q # unchanged in colemak
      #map global normal w w # unchanged
      map global normal F E
      map global normal P R
      map global normal G T
      map global normal J Y
      map global normal L U
      map global normal U I  #insert key
      map global normal Y O
      map global normal ':' P
      #row 2 (home row)
      #map global normal A A
      map global normal R S
      map global normal S D
      map global normal T F
      map global normal D G 
      
      #map global normal H H 
      map global normal N J
      map global normal E K
      map global normal I L
      map global normal O ':' #Needs quotes so ; is not a command separator
      #row 3
      #map global normal Z Z
      #map global normal X X
      #map global normal C C
      #map global normal V V
      #map global normal B B
      map global normal K N
      #map global normal M M
      # --- goto mode: invert to QWERTY, same logic as normal mode ---
      # built-in goto commands, moved onto their QWERTY physical keys
      map global goto f e   -docstring 'buffer end'
      map global goto e k   -docstring 'buffer top'
      map global goto d g   -docstring 'buffer top'
      map global goto n j   -docstring 'buffer bottom'
      map global goto u i   -docstring 'first non-blank'
      map global goto i l   -docstring 'line end'
      map global goto g t   -docstring 'window top'
      map global goto t f   -docstring 'open selected file'
      # LSP — gd follows a link / jumps to definition, gr lists backlinks
      map global goto s '<esc>:lsp-definition<ret>'  -docstring 'definition / follow link'
      map global goto p '<esc>:lsp-references<ret>'   -docstring 'references / backlinks'
      '';
  };
}

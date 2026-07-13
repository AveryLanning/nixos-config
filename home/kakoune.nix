{ pkgs, ... }:
{
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
      eval %sh{kak-lsp}

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

      # Recent versions stopped adding these by default — add them back
      map global goto s '<esc>:lsp-definition<ret>'      -docstring 'LSP definition'
      map global goto p '<esc>:lsp-references<ret>'       -docstring 'LSP references'

      # Optional: restore the breadcrumb in the modeline
      set-option global modelinefmt "%opt{lsp_modeline} %opt{modelinefmt}"


      set-option global tabstop 2
      set-option global indentwidth 2

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

{ ... }:
{
  home.file.".visidatarc".text = ''
    # Colemak physical-position remap, same method as kakoune/Nyxt/vimium:
    # each key is bound to whatever Colemak types at the ORIGINAL vim-
    # convention key's physical position, so muscle memory carries over.
    #
    # This required chasing down every stock VisiData command that already
    # occupied one of our target keys (several live in visidata/features/,
    # which an earlier pass of this file missed) and giving each of THEM
    # their own correct physical-position relocation in turn, so nothing
    # gets silently killed -- just moved.

    # --- unbind every original key being relocated, first ---
    vd.unbindkey('j')
    vd.unbindkey('k')
    vd.unbindkey('l')
    vd.unbindkey('gg')
    vd.unbindkey('G')
    vd.unbindkey('gh')
    vd.unbindkey('gl')
    Sheet.unbindkey('e')
    Sheet.unbindkey('d')
    Sheet.unbindkey('s')
    Sheet.unbindkey('t')
    Sheet.unbindkey('u')
    Sheet.unbindkey('y')
    Sheet.unbindkey('p')
    BaseSheet.unbindkey('U')
    Sheet.unbindkey('f')
    Sheet.unbindkey('r')
    Sheet.unbindkey(';')
    Sheet.unbindkey('n')
    Sheet.unbindkey('i')
    Sheet.unbindkey('L')
    BaseSheet.unbindkey('o')
    Sheet.unbindkey('I')

    # --- scroll/movement cluster (matches kakoune/Nyxt: h/n/e/i) ---
    # h (go-left) is untouched -- Colemak doesn't move that key.
    vd.bindkey('n', 'go-down')
    vd.bindkey('e', 'go-up')
    vd.bindkey('i', 'go-right')
    vd.bindkey('dd', 'go-top')
    vd.bindkey('D', 'go-bottom')
    vd.bindkey('dh', 'go-leftmost')
    vd.bindkey('di', 'go-rightmost')

    # --- edit-cell relocates to free "e" for go-up above ---
    Sheet.bindkey('f', 'edit-cell')          # physical E -> Colemak f

    # --- row operations ---
    Sheet.bindkey('s', 'delete-row')         # physical D -> Colemak s
    Sheet.bindkey('r', 'select-row')         # physical S -> Colemak r
    Sheet.bindkey('g', 'stoggle-row')        # physical T -> Colemak g
    Sheet.bindkey('l', 'unselect-row')       # physical U -> Colemak l
    Sheet.bindkey('j', 'copy-row')           # physical Y -> Colemak j
    Sheet.bindkey(';', 'paste-after')        # physical P -> Colemak ;
    BaseSheet.bindkey('L', 'undo-last')      # physical Shift+U -> Colemak L

    # --- displaced stock commands, relocated to their OWN correct
    #     physical-position targets so they stay reachable ---
    Sheet.bindkey('t', 'setcol-fill')        # physical F -> Colemak t
    Sheet.bindkey('p', 'search-keys')        # physical R -> Colemak p
    Sheet.bindkey('o', 'addcol-capture')     # the ";" key itself -> Colemak o
    Sheet.bindkey('k', 'search-next')        # physical N -> Colemak k
    Sheet.bindkey('u', 'addcol-incr')        # physical I -> Colemak u
    Sheet.bindkey('I', 'slide-right')        # physical Shift+L -> Colemak I
    BaseSheet.bindkey('y', 'open-file')      # physical O -> Colemak y
    Sheet.bindkey('U', 'describe-sheet')     # physical Shift+I -> Colemak U
  '';
}

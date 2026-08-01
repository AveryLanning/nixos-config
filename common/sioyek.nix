{ ... }:
{
  home.file.".config/sioyek/keys_user.config".text = ''
    # Colemak physical-position remap, same method as kakoune/Nyxt/vimium/
    # VisiData/yazi: each key is bound to whatever Colemak types at the
    # ORIGINAL vim-convention key's physical position.
    #
    # Note: sioyek's h/j/k/l don't mean navigate/scroll here, unlike every
    # other tool -- h is add_highlight, j/k are visual-mark up/down (an
    # annotation feature), l is overview_definition. Basic scrolling is
    # space/shift-space/pageup/pagedown, not letter-driven, so there's no
    # "hjkl scroll cluster" to preserve the way there was elsewhere. This
    # covers the vim-ish shortcuts that DO exist plus other frequently-used
    # single-key commands.
    #
    # Sioyek merges default and user keybindings into one combined tree,
    # last-definition-wins on an exact key match (verified from source),
    # so no separate unbind step is needed for direct same-key relocations.
    #
    # PERMANENT constraint, not a temporary deferral: goto_toc ("t") and
    # open_link ("f") cannot be relocated onto bare "g", ever, as long as
    # "gg" stays alive as a legacy alt below -- a node in sioyek's key tree
    # is either a complete command that fires immediately, or a pending
    # prefix, never both with graceful fallback (confirmed from source).
    # Making "g" a complete binding would permanently break every
    # g-prefixed sequence, including the ones relocated below. So
    # goto_toc/open_link stay on "t"/"f" for good.
    #
    # IMPORTANT: sioyek only treats a line as a comment if "#" is the very
    # first character -- there is no trailing/inline comment support. Every
    # explanation below is on its own line for exactly that reason.

    # --- search / goto ---
    # next_item: was n -- physical N -> Colemak k
    next_item k
    # previous_item: was N -- Colemak K
    previous_item K
    # goto_beginning: additional alt; physical G,G -> Colemak d,d
    goto_beginning dd
    # goto_end: additional alt; Colemak D
    goto_end D

    # --- annotation navigation (not scrolling -- see note above) ---
    # move_visual_mark_up: was k -- physical K -> Colemak e
    move_visual_mark_up e
    # move_visual_mark_down: was j -- physical J -> Colemak n
    move_visual_mark_down n

    # --- documents ---
    # open_document: was o -- physical O -> Colemak y
    open_document y
    # open_prev_doc: was O -- Colemak Y
    open_prev_doc Y

    # --- rotate ---
    # rotate_clockwise: was r -- physical R -> Colemak p
    rotate_clockwise p
    # rotate_counterclockwise: was R -- Colemak P
    rotate_counterclockwise P

    # --- search ---
    # external_search: was s -- physical S -> Colemak r
    external_search r

    # --- portals ---
    # portal: was p -- physical P -> Colemak ;
    portal ;
    # edit_portal: was P -- Colemak :
    edit_portal :

    # --- misc ---
    # command: was the literal colon key -> Colemak O
    command O
    # keyboard_smart_jump: was F -- Colemak T
    keyboard_smart_jump T

    # --- g-prefixed shortcuts, relocated to d-prefixed (physical G -> d) ---
    # next_chapter: was gc -- c is unchanged under Colemak
    next_chapter dc
    # prev_chapter: was gC
    prev_chapter dC
    # goto_bookmark: was gb -- freed by delete_bookmark moving to sb below
    goto_bookmark db
    # goto_bookmark_g: was gB
    goto_bookmark_g dB
    # goto_highlight: was gh -- freed by delete_highlight moving to sh below
    goto_highlight dh
    # goto_highlight_g: was gH
    goto_highlight_g dH
    # goto_next_highlight: was gnh -- physical N -> Colemak k, h unchanged
    goto_next_highlight dkh
    # goto_prev_highlight: was gNh -- Colemak K
    goto_prev_highlight dKh
    # goto_portal: was gp -- physical P -> Colemak ;
    goto_portal d;

    # --- displaced d-prefixed commands, relocated to s-prefixed
    #     (physical D -> Colemak s) so they stay reachable ---
    # delete_highlight: was dh
    delete_highlight sh
    # delete_portal: was dp
    delete_portal s;
    # delete_bookmark: was db
    delete_bookmark sb
  '';
}

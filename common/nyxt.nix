{ pkgs, ... }:
{
  xdg.configFile."nyxt/config.lisp".text = ''
    ;;; Enable vi-style modal keybindings by default (normal/insert split,
    ;;; matching the kakoune/nushell setup). Targeting `buffer' specifically
    ;;; because that's what vi-normal-mode's own docstring recommends --
    ;;; `input-buffer' did not take effect on new buffers despite being a
    ;;; parent class of web-buffer.
    ;;; Also enables reduce-tracking-mode here in the same block (exists in
    ;;; Nyxt but isn't on by default) -- sets the user agent to Safari/macOS
    ;;; (Nyxt's own researched default, not something we're overriding) to
    ;;; avoid the qutebrowser-style blocking on sites like Lowe's/Dillons
    ;;; that reject uncommon browsers.
    ;;; Also enables dark-mode (per-WEBSITE dark styling, distinct from the
    ;;; browser-chrome theme below). Its own docstring warns that fully
    ;;; disabling it mid-session requires reloading the buffer, not just
    ;;; toggling the mode off.
    (define-configuration nyxt:buffer
      ((default-modes (append (list (quote nyxt/mode/vi:vi-normal-mode)
                                     (quote nyxt/mode/reduce-tracking:reduce-tracking-mode)
                                     (quote nyxt/mode/style:dark-mode))
                               %slot-value%))))

    ;;; Dark theme for Nyxt's own UI chrome (status bar, prompt buffer,
    ;;; menus) -- built-in preset, officially documented in Nyxt's own
    ;;; manual. This is the browser's interface, not per-website dark mode;
    ;;; websites still render however their own CSS says.
    (define-configuration nyxt:browser
      ((theme theme:+dark-theme+)))

    ;;; Colemak physical-position remap for vi-normal-mode itself:
    ;;; Insert-mode entry moves off "i" onto "u" (physical qwerty-i key emits
    ;;; Colemak "u"), freeing "i" for scroll-right below. Matches the same
    ;;; swap already made in kakoune.nix.
    (define-configuration nyxt/mode/vi:vi-normal-mode
      ((keyscheme-map
        (define-keyscheme-map
          "my-vi-normal" (list :import %slot-value%)
          nyxt/keyscheme:vi-normal
          (list
           "u" (quote nyxt/mode/vi:vi-insert-mode)
           "i" (quote scroll-right))))))

    ;;; Colemak physical-position remap for document scrolling (h/j/k/l ->
    ;;; h/n/e/i, same mapping as kakoune's normal-mode hjkl remap):
    ;;;   physical h (Colemak h) -> left   (unchanged, imported from default)
    ;;;   physical j (Colemak n) -> down
    ;;;   physical k (Colemak e) -> up
    ;;;   physical l (Colemak i) -> right
    ;;; "u" is claimed above for entering insert-mode, so undo moves to "U".
    ;;; Additional vim-idiom commands, same physical-position method:
    ;;;   yy (copy)   -> physical Y -> Colemak j  -> "j j"
    ;;;   p  (paste)  -> physical P -> Colemak ;  -> ";"
    ;;;   P  (paste-from-ring) -> Colemak :       -> ":"
    ;;;   dd (cut)    -> physical D -> Colemak s  -> "s s"
    ;;;   gg (top)    -> physical G -> Colemak d  -> "d d"
    ;;;   G  (bottom) -> Colemak D                -> "D"
    ;;; IMPORTANT: every relocated command's OLD key is explicitly nil'd below
    ;;; too. Earlier drafts only added the new key and left the old one
    ;;; active, which caused real collisions (e.g. leftover "P" for
    ;;; paste-from-clipboard-ring silently beating base-mode's new "P" for
    ;;; reload-current-buffer).
    (define-configuration nyxt/mode/document:document-mode
      ((keyscheme-map
        (define-keyscheme-map
          "my-document" (list :import %slot-value%)
          nyxt/keyscheme:vi-normal
          (list
           "n" (quote scroll-down)
           "e" (quote scroll-up)
           "i" (quote scroll-right)
           "u" (quote nyxt/mode/vi:vi-insert-mode)
           "U" (quote undo)
           "j j" (quote copy)
           ";" (quote paste)
           ":" (quote paste-from-clipboard-ring)
           "s s" (quote cut)
           "d d" (quote scroll-to-top)
           "D" (quote scroll-to-bottom)
           ;; g-prefix relocates to d-prefix (physical G -> Colemak d):
           "d h" (quote jump-to-heading)
           "d H" (quote jump-to-heading-buffers)
           ;; old keys, explicitly unbound now that they moved:
           ;; "j" deliberately NOT nil'd (unlike k/l below) -- nil appears to
           ;; be a special-cased "forward straight to the page" shortcut in
           ;; Nyxt's dispatcher, which skips the normal wait-for-longer-
           ;; sequence logic entirely and was silently blocking "j j" from
           ;; ever completing. Leaving it unmentioned reverts it to whatever
           ;; :import brought in -- harmless, since scroll-down is safely
           ;; reachable via its real key ("n") either way.
           "k" nil
           "l" nil
           "y y" nil
           "p" nil
           "P" nil
           "g g" nil
           "G" nil
           "g h" nil
           "g H" nil)))))

    ;;; base-mode ships its own, separate "u" default (reopen-buffer) that
    ;;; would otherwise be silently shadowed now that "u" means insert-mode.
    ;;; physical U -> Colemak l -> relocate reopen-buffer there.
    ;;; Also: base-mode's own default "D" (delete-current-buffer) collided
    ;;; with document-mode's new "D" (scroll-to-bottom) above -- relocating
    ;;; delete-current-buffer via the same physical-position method:
    ;;; physical Shift-D -> Colemak S -> "S".
    ;;; Remaining buffer-management remaps, same method:
    ;;;   o (set-url)             -> physical O -> Colemak y -> "y"
    ;;;   O (set-url-new-buffer)  -> Colemak Y             -> "Y"
    ;;;   R (reload-current)      -> physical R -> Colemak P -> "P"
    ;;;   r (reload-buffers)      -> Colemak p             -> "p"
    ;;; B, W, [, ], and the C-w-prefixed window commands are all unchanged
    ;;; under Colemak already (those letters sit in the same physical spot),
    ;;; so nothing to remap there.
    ;;; NOT included yet: "g"-prefixed compounds (jump-to-heading,
    ;;; switch-buffer, hint-nosave-buffer) and standalone "d" (delete-buffer)
    ;;; -- their physical-position targets collide 3 ways with "dd" above.
    ;;; Confirm "dd" (scroll-to-top) still behaves cleanly on its own first.
    (define-configuration nyxt:base-mode
      ((keyscheme-map
        (define-keyscheme-map
          "my-base" (list :import %slot-value%)
          nyxt/keyscheme:vi-normal
          (list
           "l" (quote reopen-buffer)
           "S" (quote delete-current-buffer)
           "y" (quote set-url)
           "Y" (quote set-url-new-buffer)
           "P" (quote reload-current-buffer)
           "p" (quote reload-buffers)
           ;; TEMP DIAGNOSTIC: copy-url writes a known string to the
           ;; clipboard, no DOM interaction, unlike copy/cut/paste. Testing
           ;; whether it works via keybinding where those didn't.
           ;; g-prefix relocates to d-prefix, same as document-mode:
           "d b" (quote switch-buffer)
           ;; delete-buffer's physical-position target ("s") collides with
           ;; "s s" (cut) -- picked "x" instead (common close/delete
           ;; convention) since every genuinely free key needed to be
           ;; checked against the full cross-mode inventory anyway.
           "x" (quote delete-buffer)
           ;; old keys, explicitly unbound now that they moved:
           "u" nil
           "D" nil
           "o" nil
           "O" nil
           "R" nil
           "r" nil
           "g b" nil
           ;; standalone "d" nil'd -- required to free the "d" prefix for
           ;; "d b"/"d d"/"d h" etc, since a standalone complete binding on
           ;; "d" would fire immediately and block any longer sequence from
           ;; ever completing.
           "d" nil)))))

    ;;; Fix hint-mode's input focus: it has its own "hinting-type" slot,
    ;;; independent of the vi keyscheme, that defaults to :emacs (uses the
    ;;; full prompt-buffer, which needs a click to focus). :vi collapses the
    ;;; prompt to the input area and focuses it automatically -- this is the
    ;;; actual fix for "have to click before typing hint letters".
    ;;; Also: hint-mode's stock "; f" (follow-hint-new-buffer) made plain ";"
    ;;; look like a prefix of a longer sequence to Nyxt's dispatcher, so our
    ;;; document-mode ";" -> paste binding never got to fire (Nyxt just kept
    ;;; waiting for a second key, logging "Pressed keys: ;" instead of
    ;;; running paste). Nil it so ";" resolves immediately.
    ;;; Also: the hint-trigger itself was never relocated -- it's been
    ;;; sitting on stock "f" this whole time (physical-E under Colemak, an
    ;;; arbitrary spot). Move it to its real physical-position target:
    ;;; physical F -> Colemak t. Same for its g-prefixed nosave variants.
    (define-configuration nyxt/mode/hint:hint-mode
      ((hinting-type :vi)
       (keyscheme-map
        (define-keyscheme-map
          "my-hint" (list :import %slot-value%)
          nyxt/keyscheme:vi-normal
          (list
           "t" (quote follow-hint)
           "T" (quote follow-hint-new-buffer-focus)
           "d t" (quote follow-hint-nosave-buffer)
           "d T" (quote follow-hint-nosave-buffer-focus)
           "; f" nil
           "f" nil
           "F" nil
           "g f" nil
           "g F" nil)))))

    ;;; prompt-buffer (used by hint-mode, set-url, and most other quick
    ;;; dialogs) is itself a subclass of `buffer', so it inherits
    ;;; vi-normal-mode from the top-level `buffer' configuration above --
    ;;; that's why these dialogs open in normal-mode, requiring a manual
    ;;; switch to insert before typing. Default it to vi-insert-mode instead,
    ;;; since these dialogs exist to type into.
    (define-configuration nyxt:prompt-buffer
      ((default-modes (pushnew (quote nyxt/mode/vi:vi-insert-mode) %slot-value%))))
  '';
}

{ pkgs, ... }:
{
  xdg.configFile."nyxt/init.lisp".text = ''
    ;;; Enable vi-style modal keybindings by default (normal/insert split,
    ;;; matching the kakoune/nushell setup).
    (define-configuration input-buffer
      ((default-modes (pushnew (quote nyxt/mode/vi:vi-normal-mode) %slot-value%))))

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
           "U" (quote undo))))))
  '';
}

{ ... }:
{
  xdg.configFile."yazi/keymap.toml".text = ''
    [mgr]
    prepend_keymap = [
    	# Colemak physical-position remap, same method as kakoune/Nyxt/
    	# vimium/VisiData: each key is bound to whatever Colemak types at
    	# the ORIGINAL vim-convention key's physical position.
    	#
    	# Safety note (verified against yazi's actual Rust source, not
    	# assumed): prepend_keymap entries are always placed before the
    	# built-in defaults and checked first on a strict first-match-wins
    	# basis, so every binding below fully supersedes whatever
    	# previously lived on that key -- no separate unbind step needed,
    	# and no risk of e.g. a relocated "remove" command firing
    	# accidentally from a leftover single-key binding.
    	#
    	# A few old keys (lowercase l, uppercase L, "g g") are left as
    	# harmless legacy duplicates rather than explicitly cleared --
    	# confirmed none of them are part of any sequence that could create
    	# an ambiguity, they just remain as an extra (oddly-positioned)
    	# way to trigger the same now-relocated action.

    	# --- movement (matches kakoune/Nyxt/VisiData: h/n/e/i) ---
    	# h (leave/parent) is untouched -- Colemak doesn't move that key.
    	{ on = "n", run = "arrow next", desc = "Next file" },
    	{ on = "e", run = "arrow prev", desc = "Previous file" },
    	{ on = "i", run = "enter", desc = "Enter the child directory" },
    	{ on = [ "d", "d" ], run = "arrow top", desc = "Go to top" },
    	{ on = "D", run = "arrow bot", desc = "Go to bottom" },
    	# H (back) is untouched -- Colemak doesn't move that key.
    	{ on = "I", run = "forward", desc = "Forward to next directory" },

    	# --- preview seeking ---
    	{ on = "E", run = "seek -5", desc = "Seek up 5 units in the preview" },
    	{ on = "N", run = "seek 5", desc = "Seek down 5 units in the preview" },

    	# --- open / yank / paste ---
    	{ on = "y", run = "open", desc = "Open selected files" },
    	{ on = "Y", run = "open --interactive", desc = "Open selected files interactively" },
    	{ on = "j", run = "yank", desc = "Yank selected files (copy)" },
    	{ on = ";", run = "paste", desc = "Paste yanked files" },
    	{ on = ":", run = "paste --force", desc = "Paste yanked files (overwrite if the destination exists)" },
    	{ on = "J", run = "unyank", desc = "Cancel the yank status" },
    	# x/X (cut / alt-unyank) are untouched -- Colemak doesn't move those keys.

    	# --- delete / create / rename ---
    	{ on = "s", run = "remove", desc = "Trash selected files" },
    	{ on = "S", run = "remove --permanently", desc = "Permanently delete selected files" },
    	# a/A (create / bulk create) are untouched.
    	{ on = "p", run = "rename --cursor=before_ext", desc = "Rename selected file(s)" },

    	# --- shell ---
    	{ on = "o", run = "shell --interactive", desc = "Run a shell command" },
    	{ on = "O", run = "shell --block --interactive", desc = "Run a shell command (block until finishes)" },
    	# . (hidden toggle) is untouched.

    	# --- search ---
    	{ on = "r", run = "search --via=fd", desc = "Search files by name via fd" },
    	{ on = "R", run = "search --via=rg", desc = "Search files by content via ripgrep" },
    	{ on = "k", run = "find_arrow", desc = "Next found" },
    	{ on = "K", run = "find_arrow --previous", desc = "Previous found" },
    	# v/V (visual mode) and z/Z (fzf/zoxide plugins) are untouched.
    ]
  '';
}

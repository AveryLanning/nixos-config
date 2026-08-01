{pkgs, ...}:
{
  home.file."notes/.zk/config.toml".text = ''
    # zk configuration file
    #
    # Uncomment the properties you want to customize.

    # NOTE SETTINGS
    [note]
    #language = "en"
    default-title = "Untitled" #Keeps the filename from being an empty string to start with
    filename = "{{slug title}}-{{id}}"
    #extension = "md"
    template = "default.md"
    exclude = [
        "attachments/*"
    ]
    #id-charset = "alphanum"
    #id-length = 4
    #id-case = "lower"

    # EXTRA VARIABLES
    [extra]
    #key = "value"

    # GROUP OVERRIDES
    #[group."<NAME>"]
    #paths = ["<DIR1>", "<DIR2>"]
    #[group."<NAME>".note]
    #filename = "{{format-date now}}"
    #[group."<NAME>".extra]
    #key = "value"

    # MARKDOWN SETTINGS
    [format.markdown]
    link-format = "wiki"
    #link-encode-path = true
    #link-drop-extension = true
    hashtags = true
    colon-tags = false
    multiword-tags = true

    # EXTERNAL TOOLS
    [tool]
    #editor = "vim"
    #pager = "less -FIRX"
    #fzf-preview = "bat -p --color always {-1}"

    # LSP
    [lsp]
    [lsp.diagnostics]
    #wiki-title = "hint"
    dead-link = "error"
    #self-link = "warning"
    #missing-backlink = { level = "hint", position = "bottom" }
    [lsp.completion]
    #note-label = "{{title-or-path}}"
    #note-filter-text = "{{title}} {{path}}"
    #note-detail = "{{filename-stem}}"

    # NAMED FILTERS
    [filter]
    #recents = "--sort created- --created-after 'last two weeks'"

    # COMMAND ALIASES
    [alias]
    #ls = "zk list $@"
    #list = "zk list --quiet $@"
    #editlast = "zk edit --limit 1 --sort modified- $@"
    #recent = "zk edit --sort created- --created-after 'last two weeks' --interactive"
    #path = "zk list --quiet --format {{path}} --delimiter , $@"
    #lucky = "zk list --quiet --format full --sort random --limit 1"
    #hist = "zk list --format path --delimiter0 --quiet $@ | xargs -t -0 git log --patch --"
    #conf = '$EDITOR "$ZK_NOTEBOOK_DIR/.zk/config.toml"'
  '';

  home.file."notes/.zk/templates/default.md".text = ''
    # {{title}}
    {{content}}
  '';

    home.file.".local/bin/zk-mitosis" = {
    executable = true;
    text = ''
      #!${pkgs.nushell}/bin/nu
      def run []: string -> string {
          let body = $in
          let title = $env.ZK_TITLE
          let path = ($body | zk new --title $title --print-path)
          let relpath = (realpath --relative-to $"($env.HOME)/notes" $path | str trim)
          $"[($title)]" + "(" + $relpath + ")"
      }

      ^cat | run
    '';
  };

 home.file.".local/bin/zk-picker" = {
    executable = true;
    text = ''
      #!${pkgs.nushell}/bin/nu
      with-env {SHELL: "${pkgs.bash}/bin/bash"} {
          zk edit -i
      }
    '';
  };

  home.file.".local/bin/zk-sketch" = {
    executable = true;
    text = ''
      #!${pkgs.nushell}/bin/nu
      def main [buffile: string, session: string, client: string] {
          let attach_dir = $"($env.HOME)/notes/attachments"
          mkdir $attach_dir
          let before = (ls $attach_dir | where name =~ '\.rnote$' | get name)

          cd $attach_dir
          ^rnote

          let after = (ls $attach_dir | where name =~ '\.rnote$' | get name)
          let new_files = ($after | where {|f| not ($f in $before)})

          if ($new_files | is-empty) {
              print "zk-sketch: no new .rnote file detected, aborting"
              return
          }

          let stem = ($buffile | path parse | get stem)
          let timestamp = (date now | format date "%Y%m%d-%H%M%S")
          let auto_name = $"($stem)-sketch-($timestamp).rnote"
          let orig_path = ($new_files | first)
          mv $orig_path $auto_name

          let base = ($auto_name | path parse | get stem)
          let svg_path = $"($attach_dir)/($base).svg"

          print $"zk-sketch: exporting ($auto_name) -> ($svg_path)"
          ^rnote-cli export doc --output-file $svg_path --on-conflict overwrite $auto_name

          if not ($svg_path | path exists) {
              print "zk-sketch: export failed, no svg produced"
              return
          }

          let md = $"\n![Sketch]\(attachments/($base).svg) [Edit diagram]\(attachments/($auto_name)\)\n"
          let tmpfile = (mktemp)
          $md | save -f $tmpfile

          let cmd = $"evaluate-commands -client '($client)' -- 'execute-keys \"<esc><a-!>cat ($tmpfile)<ret>\"'"
          $cmd | ^kak -p $session
          print "zk-sketch: link inserted"
      }
    '';
  };
}

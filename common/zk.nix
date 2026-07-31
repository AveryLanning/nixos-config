{pkgs, ...}:
{
  home.file."notes/.zk/config.toml".text = ''
    [notebook]
    dir = "/home/avery/notes"

    [note]
    filename = "{{slug title}}"
    extension = "md"
    template = "default.md"
    id-charset = "alphanum"
    id-length = 4
    id-case = "lower"

    [tool]
    fzf-preview = "bat -p --color always {-1}"
    fzf-line-format = "{{title}} {{tags}}"
  '';

  home.file."notes/.zk/templates/default.md".text = ''
    ---
    title: {{title}}
    date: {{format-date now "medium"}}
    tags: [{{tags}}]
    ---

    {{content}}
  '';

  home.file.".local/bin/zk-mitosis" = {
    executable = true;
    text = ''
      #!/usr/bin/env nu
      let content = $in
      let lines = ($content | lines)
      let title = ($lines | first | str replace -r '^#+\s*' '')
      let body = ($lines | skip 1 | str join "\n")
      let path = ($body | zk new --title $title --print-path -)
      let relpath = (realpath --relative-to $"($env.HOME)/notes" $path | str trim)
      $"[($title)]\(($relpath)\)"
    '';
  };
}

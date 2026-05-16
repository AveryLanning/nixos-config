{ config, pkgs, ... }:

{
  home.username = "avery";
  home.homeDirectory = "/home/avery";

  home.stateVersion = "24.05";

  home.sessionVariables = {
    EDITOR = "kak";
    VISUAL = "kak";
  };

  programs.bash.enable = true;

  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;

    keymap = {
      manager = {
        append_keymap = [
          {
            on = [ "z" ];
            run = "quit";
            desc = "quit";
          }
        ];
      };
    };
  };

  programs.kakoune = {
    enable = true;

    extraConfig = "

      #Remapping so all command keys remain in their original position

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
      ";
  };

  xresources.properties = {
    "XTerm*background" = "#000000";
    "XTerm*foreground" = "#f8f8f2";

    "XTerm*cursorColor" = "#ff5555";

    "XTerm*color0"  = "#000000";
    "XTerm*color1"  = "#ff5555";
    "XTerm*color2"  = "#50fa7b";
    "XTerm*color3"  = "#f1fa8c";
    "XTerm*color4"  = "#bd93f9";
    "XTerm*color5"  = "#ff79c6";
    "XTerm*color6"  = "#8be9fd";
    "XTerm*color7"  = "#bbbbbb";

    "XTerm*faceName" = "monospace";
    "XTerm*faceSize" = 11;
  };

  home.packages = with pkgs; [
    
  ];
}

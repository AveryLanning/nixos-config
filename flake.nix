{
  description = "NixOS config with Home Manager";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, home-manager, ... }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations.averyNix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.avery = import ./home.nix;
        }
      ];
    };

    devShells.x86_64-linux.python = pkgs.mkShell {
      packages = [
        (pkgs.python3.withPackages (ps: with ps; [
          # numpy
          # requests
        ]))
        pkgs.nushell
      ];

      shellHook = ''
        exec nu
      '';
    };
  };
}

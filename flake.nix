{
  description = "NixOS config with Home Manager";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, home-manager, ... }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    homeManagerModule = user: import user;
  in {
    nixosConfigurations.averyNix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/laptop/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.avery = import ./hosts/laptop/home.nix;
        }
      ];
    };
    nixosConfigurations.averyServer = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/server/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.avery = import ./hosts/server/home.nix;
        }
      ];
    };
    devShells.x86_64-linux.python = pkgs.mkShell {
      packages = [
        (pkgs.python3.withPackages (ps: with ps; [
        ]))
        pkgs.nushell
      ];
      shellHook = ''
        exec nu
      '';
    };
  };
}

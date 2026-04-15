{
  description = "Declarative NAS flake providing UGreen LED controller & kernel Nix module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in
    {
      nixosModules = {
        default = self.nixosModules.nixnas;
        nixnas = ./modules;
      };

      overlays.default = final: prev: {
        ugreen-leds = prev.callPackage ./pkgs/ugreen-leds { };
      };

      # 'nix build .#package' - inputs.nixnas.packages.${system}.<package>
      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        self.overlays.default pkgs pkgs
      );
    };
}

{
  description = "STM32 embedded dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShellNoCC {
      packages = with pkgs; [
        cmake
        ninja
        gcc-arm-embedded
        openocd
        gdb
      ];
    };
  };
}

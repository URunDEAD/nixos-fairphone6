{
  description = "Desktop-neutral NixOS / Mobile NixOS support for the Fairphone (Gen. 6)";
  inputs = {
    nixpkgs.url = "https://releases.nixos.org/nixos/unstable/nixos-26.11pre1031299.0bb7ec54c848/nixexprs.tar.xz";
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos/2c132754323fc1915e8d21dcfc0ef68ab084c6fb";
      flake = false;
    };
    fairphone6-hardware = {
      url = "git+https://github.com/URunDEAD/linux-fairphone6.git?rev=0e4b6f92723d3c345aa4da93646ccd6ab2ea744f";
      flake = false;
    };
  };
  outputs = inputs@{ self, nixpkgs, mobile-nixos, fairphone6-hardware }:
    let
      packagesFor = pkgs: import ./packages { inherit pkgs; hardwareSource = fairphone6-hardware; };
      # The two small upstream compatibility patches are kept with hardware sources.
      patchedMobileFor = pkgs: pkgs.applyPatches {
        name = "mobile-nixos-handsets";
        src = mobile-nixos;
        patches = [
          "${fairphone6-hardware}/compatibility/mobile-nixos/initrd-zstd.patch"
          "${fairphone6-hardware}/compatibility/mobile-nixos/ffs-module.patch"
        ];
      };
    in {
      packages.aarch64-linux = packagesFor nixpkgs.legacyPackages.aarch64-linux;
      nixosModules = {
        common = import ./modules;
        fairphone6 = import ./devices/fairphone6;
        development = import ./modules/development.nix;
      };
      lib = {
        inherit packagesFor patchedMobileFor;
        # No implicit developer credentials, root layout, firmware or image target.
        mkFairphone6 = { configuration, buildSystem ? "x86_64-linux" }:
          let mobileSource = patchedMobileFor nixpkgs.legacyPackages.${buildSystem};
          in nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs.handsetPackages = packagesFor nixpkgs.legacyPackages.aarch64-linux;
            modules = [
              (import "${mobileSource}/lib/configuration.nix" { device = null; })
              self.nixosModules.common
              self.nixosModules.fairphone6
              configuration
            ];
          };
      };
    };
}

# Inputs and validation before building

The repository is private. Fetch the pinned hardware input using a Git credential helper or a temporary askpass environment scoped to GitLab. Never place tokens in flake URLs, lockfiles or source. Remove credential-bearing environment variables before builds.

## Required external inputs

1. Verified milos-linux source archive for revision `63289f4411520a2acb38bd533437446d33fbce74`, SHA256 `1a1aba170899273cbb97bce2dc0713957340a7be2e2d187faab6f821d60687ba`. Follow the hardware repository's archive recipe, then register that file with Nix under the required filename; `pkgs.requireFile` fails if unavailable.
2. A lawfully obtained firmware archive with a `firmware/` tree. `packages/firmware-fairphone6.nix` converts that supplied archive into a package. Never commit firmware, trustlets or calibration data. A Nix store import is not private storage; do not import personal calibration/secrets or publish firmware through a cache without rights review.
3. A matching, verified Android v2 boot template. The preserved repacker requires SHA256 `98ed20373d229a5ebac482f81f7f601150137db3d9f5220ef8b6d6feab781cf8` and checks header/size/load bounds. Do not weaken these assertions to accept an unrelated image.
4. Explicit root filesystem device and any needed stage-1 discovery tasks. There is no inherited UUID, nested userdata mount, partition formatting or installation routine.

## Consumer composition

In a consumer flake with this repository as an input named `handsets`:

```nix
nixosConfigurations.phone = handsets.lib.mkFairphone6 {
  configuration = { pkgs, ... }: {
    imports = [ "${handsets}/images/fairphone6-reference.nix" ];
    handsets.fairphone6 = {
      firmwarePackage = pkgs.callPackage "${handsets}/packages/firmware-fairphone6.nix" {
        firmwareArchive = /absolute/path/to/verified-firmware.tar;
      };
      bootTemplate = /absolute/path/to/verified-template.img;
      rootDevice = "/dev/disk/by-label/YOUR_VERIFIED_ROOT";
    };
  };
};
```

Paths are placeholders, not shipped assets. Replace them in private local configuration. The example does not provision a usable login or debug transport. Explicitly import the development module and supply a public key if SSH is needed; configure suitable network access separately. Do not commit credentials or enable generic password access.

`config.system.build.toplevel` and `config.mobile.outputs.android.android-bootimg` are intended build outputs once inputs and assertions are satisfied. They remain unqualified on hardware. Source patching may require import-from-derivation during evaluation; it is separate from full AArch64 image builds.

## Follow-up qualification

Before booting: build on a suitable AArch64 builder; verify initrd/kernel/modules/DTB agreement, firmware inventory, root discovery, load addresses and complete system closure. Establish a recovery path and a supervised RAM-boot procedure separately. Do not flash, change slots or activate a system as part of static checks. Reference builds do not preserve the original phone's nested-root setup automatically.

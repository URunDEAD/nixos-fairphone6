# Repository boundaries and interfaces

One hardware repository per phone, named `linux-<phone>` ([linux-fairphone6](https://github.com/URunDEAD/linux-fairphone6) for the FP6). This repository contains common NixOS modules plus `devices/<phone>` integrations. Promote a device-specific module to common only when another phone needs it. Shared upstream forks are optional; Mobile NixOS is currently pinned upstream with two explicit compatibility patches from the FP6 hardware repository.

Hardware repositories own patch contents, configs, drivers and hardware helpers. This repository owns packaging, dependency composition, boot/initramfs assembly and service activation. Velrune System owns the desktop, app selection, permission experience and product update policy. Other NixOS consumers can select another desktop or none.

## Public entry points

- `nixosModules.common`: declares `handsets.audio.enable`, `handsets.networking.enable`, and `handsets.sensors.enable`; all default off.
- `nixosModules.fairphone6`: requires Mobile NixOS modules and `handsetPackages` as a special argument. Defines explicit `handsets.fairphone6.firmwarePackage`, `rootDevice`, `bootTemplate`, and an overridable `kernelPackage`.
- `nixosModules.development`: `handsets.development.enable` defaults off. Opt-in key-only SSH requires `authorizedKeys`; no automatic wheel membership or passwordless sudo.
- `lib.packagesFor pkgs`: hardware package set for the caller's package set. Device use requires AArch64.
- `lib.patchedMobileFor pkgs`: pinned Mobile NixOS source with the two maintained patches applied. Evaluating module imports may realize this small source-patching derivation.
- `lib.mkFairphone6 { configuration; buildSystem ? "x86_64-linux"; }`: compose Mobile NixOS, common and board modules with explicit consumer configuration. `buildSystem` selects the host used for source patching, not a claim of cross-compilation support for the complete image.

Packages are not enabled merely by being exposed. Camera, modem/IMS, fingerprint and Bluetooth activation remain separate follow-up work; exposing their packages does not promise working calls, enrollment or pairing. Audio defaults omit experimental voice routing and top-mic changes. FP6 suspend remains disabled until qualified.

OS update activation, boot-slot recovery and firmware updates require further design/validation. This layer provides mechanics, not a Velrune release policy or a safe automatic rollback claim.

## Next integration work

1. Validate the real firmware inventory and boot template without committing binaries.
2. Define and review a per-device root discovery and recovery procedure; preserve the existing installation.
3. Build and qualify matching kernel, initrd, modules and DTB on AArch64 before a separately authorized RAM boot.
4. Extract remaining modem, Bluetooth, camera and power activation as independent opt-in modules, without desktop policy.
5. Consume pinned modules from Velrune System; keep that product integration outside this repository.

The historical hardware recipes remain in the hardware repository for reproducibility. This initial integration references existing userspace recipes rather than copying them; future packaging-only changes belong here, with a coordinated pin/update when ownership moves.

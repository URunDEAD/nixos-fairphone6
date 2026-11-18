# nixos-fairphone6: NixOS on the Fairphone (Gen. 6)

Desktop-neutral NixOS / Mobile NixOS integration for the Fairphone (Gen. 6) (SM7635 / "milos"). This is the integration layer between the hardware sources in [linux-fairphone6](https://github.com/URunDEAD/linux-fairphone6) and consumers such as a desktop shell or Velrune OS.

> **Unofficial community project.** Not affiliated with, endorsed by or supported by Fairphone B.V. or the Mobile NixOS project.

## Related repositories

| Repository | Role |
|---|---|
| [linux-fairphone6](https://github.com/URunDEAD/linux-fairphone6) | Linux hardware enablement: kernel, drivers, device tree, ALSA/libcamera, modem helpers. Pinned by this flake |
| **nixos-fairphone6** (this) | NixOS / Mobile NixOS packaging, device modules, reference image |
| [lomiri-fairphone6](https://github.com/URunDEAD/lomiri-fairphone6) | Lomiri/Mir shell, Phosh and Ubuntu Touch apps on NixOS: the original full-stack port |
| Velrune OS (private) | A consumer of this layer |

## History

Until 2026-11-18 this repository was `fairphone6-nixos`, an all-in-one port with hardware enablement, NixOS, Lomiri, Phosh and apps together. That state, which booted and ran Lomiri on the phone, is preserved at tag [`lomiri-final`](https://github.com/URunDEAD/nixos-fairphone6/tree/lomiri-final) and continues in [lomiri-fairphone6](https://github.com/URunDEAD/lomiri-fairphone6). Hardware work moved to [linux-fairphone6](https://github.com/URunDEAD/linux-fairphone6). This repository now holds only the NixOS layer.

## Layout

| Directory | Responsibility |
|---|---|
| `modules/` | Opt-in common networking, audio, sensors and explicit development access |
| `devices/fairphone6/` | Board configuration, boot-image assembly, audio/sensor wiring |
| `packages/` | Nix packaging referencing pinned hardware sources |
| `images/` | Minimal desktop-free reference configuration |
| `tests/` | Static/evaluation checks, not device tests |
| `docs/` | Interfaces, build inputs, provenance and qualification |

`flake.lock` pins nixpkgs, Mobile NixOS and the hardware repository. Raw patches, drivers and hardware facts stay in phone repositories. Original Nix recipes there remain provenance/reference material; this repository owns maintained OS-facing packaging and activation. No complete desktop configuration is imported from the old port.

No Lomiri, Mir, Phosh, Velrune, app suite or update UI is selected; see the related repositories for those. Existing hardware limitations remain. New modules and the reference image have not been booted; do not infer readiness from successful parsing or evaluation.

See [architecture](docs/ARCHITECTURE.md), [building](docs/BUILDING.md) and [provenance](docs/PROVENANCE.md). No hardware actions, full builds or production deployment are part of this extraction.

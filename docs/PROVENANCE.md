# Provenance and current scope

Hardware source: [linux-fairphone6](https://github.com/URunDEAD/linux-fairphone6) at `0e4b6f92723d3c345aa4da93646ccd6ab2ea744f`. Its provenance records the original source, this repository before it became NixOS-only, at `45d07cde3611922a8302a387f4cf392c1340725f` (tag `lomiri-final`).

Mobile NixOS: upstream `2c132754323fc1915e8d21dcfc0ef68ab084c6fb`, with zstd initrd and FunctionFS module-name patches referenced from the hardware repository. nixpkgs uses the same pinned release archive as that Mobile NixOS checkpoint and the original kernel recipes.

The new common modules and composition API are authored here. FP6 metadata and boot layout derive from the original `nixos-fp6/device/default.nix`; audio routing derives from `audio-fp6.nix`; sensor quirks derive from `sensors-fp6.nix`. Kernel packaging adapts the extracted kernel6 recipe and references its unchanged patches/config. `devices/fairphone6/repack-boot.py` is byte-identical to the original `kernel-build/repack-new-kernel.py`; see source-hashes.json.

Omitted deliberately: nested userdata task/fixed UUID, original accounts, passwords, SSH defaults, ADB defaults, Lomiri/Phosh/Mir/app/Qt integration and deployment commands. This is a new curated integration repository, not a full-history mirror of the mixed original system configuration. Original authorship/history remains linked through the source repositories. The hardware extraction's filtered history is not rewritten.

Original project code retains its MIT notice; third-party patches and dependencies retain their own licenses. No vendor binaries are included. No firmware redistribution, upstream sign-off or publication of private material is implied.

Implementation status: foundational packaging/modules and explicit-input reference image configuration. Runtime boot, recovery, modem, camera and authentication qualification remain pending. See tests/README.md for exact checks performed.

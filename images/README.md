# Reference images

`fairphone6-reference.nix` is a desktop-free evaluation/build configuration, not a validated image. It enables networking, audio and sensors. No default user or remote access is created.

The caller must supply firmware, a verified boot template and an explicit root device through `lib.mkFairphone6`. The original nested userdata layout is intentionally not reused. Add a consumer-owned stage-1 task if your root cannot be discovered directly; do not use the reference configuration to repartition a phone.

There is no automatic build or flash target. Boot and recovery qualification remain pending; see ../docs/BUILDING.md.

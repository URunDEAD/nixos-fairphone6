# Validation scope

Static checks and module evaluation only. No full kernel/image build, phone connection, firmware extraction, flashing, service activation or recovery claim.

`python3 tests/static.py` checks source syntax, no embedded firmware/credentials/desktop selection, relative imports and repacker provenance. Evaluation receipts are recorded in validation.json after checks. Static checks do not certify image bootability.

Run `python3 tests/check.py` from the repository root after fetching flake inputs and staging new files. It parses sources, evaluates opt-in defaults, rejects empty development keys, checks the reference configuration has no desktop/debug access, checks its assertions with evaluation fixtures and resolves all eight package derivations. It may realize the small patched Mobile NixOS source derivation; it does not build those eight packages. The recorded phone configuration uses substitute inputs, so this does not validate real boot assets.

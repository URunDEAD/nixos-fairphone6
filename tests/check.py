"""Offline-after-fetch validation; may realize only the patched upstream source."""
from pathlib import Path
import json, subprocess, sys
root = Path(__file__).resolve().parents[1]
subprocess.run([sys.executable, "tests/static.py"], cwd=root, check=True)
evaluation = json.loads(subprocess.check_output([
    "nix", "eval", "--impure", "--json", "--expr",
    "import ./tests/eval.nix { repo = toString ./.; }"
], cwd=root))
for key in ["commonDisabled", "optIns", "noDefaultSsh", "emptyDevelopmentKeysRejected"]:
    assert evaluation[key], key
for key in ["noDesktop", "noDebugAccess", "suspendDisabled"]:
    assert evaluation["phone"][key], key
assert evaluation["phone"]["failedAssertions"] == []
assert evaluation["phone"]["compression"] == "zstd"
assert evaluation["phone"]["rootDevice"] == "/dev/disk/by-label/EVALUATION_ONLY"
packages = json.loads(subprocess.check_output([
    "nix", "eval", "--json", ".#packages.aarch64-linux", "--apply",
    "ps: builtins.mapAttrs (_: p: p.drvPath) ps"
], cwd=root))
assert len(packages) == 8 and all(p.endswith(".drv") for p in packages.values())
print(json.dumps({"module_evaluation": evaluation, "package_derivations_evaluated": len(packages),
    "runtime_tested": False, "kernel_or_image_built": False}, indent=2))

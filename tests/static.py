from pathlib import Path
import ast, hashlib, json, re, subprocess
root = Path(__file__).resolve().parents[1]
for p in root.rglob("*.nix"):
    subprocess.run(["nix-instantiate", "--parse", str(p)], check=True, stdout=subprocess.DEVNULL)
    text = p.read_text()
    for line in text.splitlines():
        if line.lstrip().startswith("#"):
            continue
        for relative in re.findall(r"(?<![\w/])((?:\.\.?/)[A-Za-z0-9_./-]+)", line):
            assert (p.parent / relative).exists(), (p, relative)
    for forbidden in ["services.desktopManager.lomiri", "services.displayManager.defaultSession", "hashedPassword", "initialPassword", "nested-root.rb"]:
        if "tests" not in p.relative_to(root).parts:
            assert forbidden not in text, (p, forbidden)
for p in root.rglob("*.py"):
    ast.parse(p.read_text(), filename=str(p))
for row in json.loads((root / "docs/source-hashes.json").read_text())["copied"]:
    assert hashlib.sha256((root / row["path"]).read_bytes()).hexdigest() == row["sha256"]
for suffix in ["*.img", "*.mbn", "*.bin", "*.tar"]:
    assert not list(root.glob("**/" + suffix)), suffix
print("Static source checks passed")

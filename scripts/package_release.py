"""Package the committed source and already verified research outputs for release."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]

def main():
    target = ROOT / "build/release"
    target.mkdir(parents=True, exist_ok=True)
    commit = subprocess.check_output(["git","rev-parse","HEAD"],cwd=ROOT,text=True).strip()
    subprocess.run(["git","archive","--format=zip","--output",str(target/"contextuality-tensor-source.zip"),commit],cwd=ROOT,check=True)
    with zipfile.ZipFile(target/"contextuality-tensor-arxiv-source.zip","w",zipfile.ZIP_DEFLATED) as archive:
        for rel in ["contextuality-tensor.tex", "figures/gap-and-noise.pdf"]:
            archive.write(ROOT/"paper"/rel, rel)
    sources = ["paper/contextuality-tensor.pdf", "CITATION.cff", "LICENSE",
               "results/exact-certificate.json", "results/four-qubit-square.json",
               "results/lean-axioms.json", "results/lean-axioms.log",
               "results/stack_report.json", "results/stack_browser.json",
               "results/manuscript-review.md"]
    for rel in sources:
        shutil.copyfile(ROOT/rel, target/Path(rel).name)
    metadata = {"commit":commit,"version":"0.1.0","research_date":"2026-11-09",
                "title":"Exact contextuality degrees for disjoint Mermin configurations",
                "status":"Research preprint; not peer reviewed",
                "repository":"https://github.com/0thernes/contextuality-tensor-lab",
                "ai_disclosure":"Substantive AI assistance in research, derivation, coding, formalization, verification and drafting; human direction. Human author critical review and external submission declarations are tracked separately."}
    (target/"release-metadata.json").write_text(json.dumps(metadata,indent=2)+"\n",encoding="utf-8")
    hashes = {p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(target.iterdir())
              if p.is_file() and p.name != "SHA256SUMS"}
    (target/"SHA256SUMS").write_text("".join(f"{digest}  {name}\n" for name,digest in hashes.items()),encoding="utf-8")
    print(json.dumps({"commit":commit,"assets":len(hashes)+1,"path":str(target)},indent=2))

if __name__ == "__main__":
    main()

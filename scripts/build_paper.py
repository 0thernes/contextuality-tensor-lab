"""Generate original figures, portable LaTeX, public scholarly HTML, and PDF."""
from pathlib import Path
import argparse
import hashlib
import html
import json
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
STEM = "contextuality-tensor"

def figures():
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import numpy as np
    plt.rcParams.update({"font.size": 10, "font.family": "DejaVu Sans", "axes.spines.top": False,
                         "axes.spines.right": False, "savefig.bbox": "tight"})
    fig, axes = plt.subplots(1, 2, figsize=(10.6, 3.7))
    ks = np.arange(1, 13)
    axes[0].plot(ks, [(7**int(k)-5**int(k))/(7**int(k)-1) for k in ks], "o-", color="#146b81", label="Squares")
    axes[0].plot(ks, [(6**int(k)-4**int(k))/(6**int(k)-1) for k in ks], "s-", color="#bd6a25", label="Pentagrams")
    axes[0].axhline(1, color="#777777", linewidth=.8, linestyle="--")
    axes[0].set(xlabel="Number of copies k", ylabel="Ideal normalized gap 2d/L", ylim=(.25, 1.04), title="A. Exact gap approaches one")
    axes[0].legend(frameon=False)
    ps = np.linspace(0, .09, 300)
    for k, color in zip([1, 2, 4, 8], ["#123e50", "#146b81", "#d6923a", "#923c3b"]):
        margin = ((1+6*(1-2*ps)**3)**k-5**k)/(7**k-1)
        axes[1].plot(100*ps, margin, color=color, label=f"k={k}")
    pc = (1-(2/3)**(1/3))/2
    axes[1].axvline(100*pc, color="#777777", linestyle="--", linewidth=1)
    axes[1].axhline(0, color="#777777", linewidth=.8)
    axes[1].set(xlabel="Independent readout flip probability (%)", ylabel="Normalized noisy margin (Q−B)/L", title="B. Square readout threshold stays fixed")
    axes[1].legend(frameon=False, ncol=2)
    for ax in axes:
        ax.grid(alpha=.18)
    fig.tight_layout(w_pad=3)
    target = ROOT / "paper/figures"
    target.mkdir(exist_ok=True)
    for ext in ["pdf", "png"]:
        fig.savefig(target / ("gap-and-noise."+ext), dpi=180)
    plt.close(fig)

PREAMBLE = r"""\documentclass[10pt,a4paper]{article}
\usepackage[margin=23mm]{geometry}
\usepackage{amsmath,amssymb,mathtools}
\usepackage{fontspec}
\setmainfont{texgyrepagella}[Extension=.otf,UprightFont=*-regular,ItalicFont=*-italic,BoldFont=*-bold,BoldItalicFont=*-bolditalic]
\setsansfont{texgyreheros}[Extension=.otf,UprightFont=*-regular,ItalicFont=*-italic,BoldFont=*-bold,BoldItalicFont=*-bolditalic]
\setmonofont{lmmono10-regular.otf}[Scale=0.85]
\usepackage{unicode-math}
\setmathfont{texgyrepagella-math.otf}
\AtBeginDocument{\let\setminus\smallsetminus}
\usepackage{microtype,graphicx,longtable,booktabs,array,calc}
\usepackage{xcolor}
\definecolor{Accent}{HTML}{146B81}
\usepackage[colorlinks=true,linkcolor=Accent,urlcolor=Accent,citecolor=Accent]{hyperref}
\usepackage{titlesec}
\titleformat{\section}{\large\bfseries\sffamily\color{Accent}}{\thesection}{.6em}{}
\titleformat{\subsection}{\normalsize\bfseries\sffamily}{\thesubsection}{.6em}{}
\usepackage{fancyhdr}
\pagestyle{fancy}\fancyhf{}
\fancyhead[L]{\small\sffamily Exact contextuality degrees}
\fancyhead[R]{\small\sffamily Research preprint}
\fancyfoot[C]{\thepage}
\setlength{\headheight}{14pt}
\setlength{\parindent}{0pt}
\setlength{\parskip}{5pt}
\setcounter{secnumdepth}{0}
\providecommand{\tightlist}{\setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
\providecommand{\pandocbounded}[1]{#1}
\emergencystretch=3em
\hypersetup{pdftitle={Exact contextuality degrees for disjoint Mermin configurations},pdfauthor={Alexander S. Donahue; 0thernes LLC}}
\title{\vspace{-12mm}\sffamily\bfseries Exact contextuality degrees\\for disjoint Mermin configurations}
\author{Alexander S. Donahue\\\small 0thernes LLC\\\small\href{https://orcid.org/0009-0006-8168-9648}{ORCID 0009-0006-8168-9648}\\\small\href{mailto:0_0@0thernes.art}{0\_0@0thernes.art}}
\date{9 November 2026\quad\textbullet\quad Version 0.1.0}
\begin{document}
\maketitle
\begin{center}\small Research preprint; not peer reviewed. Substantive AI assistance disclosed in Section 9.\end{center}
"""

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pandoc", default=shutil.which("pandoc"))
    parser.add_argument("--tectonic", default=shutil.which("tectonic"))
    args = parser.parse_args()
    if not args.pandoc or not args.tectonic:
        parser.error("Supply --pandoc and --tectonic executables")
    figures()
    md = (ROOT / "paper" / (STEM+".md")).read_text(encoding="utf-8")
    body = "## Abstract"+md.split("## Abstract", 1)[1]
    fragment = subprocess.run([args.pandoc, "--from=markdown+tex_math_dollars", "--to=latex", "--wrap=none",
                               "--shift-heading-level-by=-1", "--no-highlight"], input=body,
                              text=True, encoding="utf-8", capture_output=True, check=True).stdout
    fragment = fragment.replace(r"\def\LTcaptype{none}", r"\def\LTcaptype{table}")
    fragment = fragment.replace("figures/gap-and-noise.png", "figures/gap-and-noise.pdf")
    fragment = fragment.replace(r"\includegraphics[", r"\includegraphics[width=\linewidth,")
    tex = PREAMBLE+fragment+"\n\\end{document}\n"
    (ROOT / "paper" / (STEM+".tex")).write_text(tex, encoding="utf-8")
    with tempfile.TemporaryDirectory(prefix="contextuality-paper-") as tmp:
        stage = Path(tmp)
        (stage / (STEM+".tex")).write_text(tex, encoding="utf-8")
        shutil.copytree(ROOT / "paper/figures", stage / "figures")
        result = subprocess.run([args.tectonic, "--untrusted", "--keep-logs", "--print", str(stage/(STEM+".tex"))],
                                cwd=tmp, capture_output=True, text=True, encoding="utf-8", errors="replace")
        (ROOT / "results/paper-build.log").write_text(result.stdout+result.stderr, encoding="utf-8")
        if result.returncode:
            raise RuntimeError("PDF build failed; see results/paper-build.log")
        shutil.copyfile(stage/(STEM+".pdf"), ROOT/"paper"/(STEM+".pdf"))
    target = ROOT / "docs/paper"
    target.mkdir(exist_ok=True, parents=True)
    for ext in ["pdf", "tex", "md"]:
        shutil.copyfile(ROOT/"paper"/(STEM+"."+ext), target/(STEM+"."+ext))
    abstract = body.split("\n## ", 1)[0].removeprefix("## Abstract").strip()
    record = f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Exact contextuality degrees for disjoint Mermin configurations</title>
<meta name="citation_title" content="Exact contextuality degrees for disjoint Mermin configurations">
<meta name="citation_author" content="Donahue, Alexander S."><meta name="citation_publication_date" content="2026/11/09">
<meta name="citation_technical_report_institution" content="0thernes LLC">
<meta name="citation_pdf_url" content="https://0thernes.github.io/contextuality-tensor-lab/paper/{STEM}.pdf">
<link rel="canonical" href="https://0thernes.github.io/contextuality-tensor-lab/paper/">
<style>body{{max-width:850px;margin:60px auto;padding:0 24px;font:18px/1.7 system-ui;color:#183c48;background:#f8faf9}}h1{{line-height:1.18;font-size:36px}}a{{color:#146b81}}.meta{{font-size:15px;color:#536d76}}nav{{display:flex;gap:24px;flex-wrap:wrap}}section{{margin-top:36px}}</style>
<script>MathJax={{tex:{{inlineMath:[['$','$']]}}}};</script><script defer src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js"></script></head>
<body><article><p class="meta">CONTEXTUALITY TENSOR LAB / RESEARCH PREPRINT</p><h1>Exact contextuality degrees for disjoint Mermin configurations</h1>
<p>Alexander S. Donahue · 0thernes LLC</p><p class="meta">9 November 2026 · Version 0.1.0 · Not peer reviewed<br>ORCID <a href="https://orcid.org/0009-0006-8168-9648">0009-0006-8168-9648</a></p>
<nav><a href="{STEM}.pdf">Read PDF</a><a href="../">Run the lab</a><a href="https://github.com/0thernes/contextuality-tensor-lab">Code and Lean proofs</a></nav>
<section><h2>Abstract</h2><p>{html.escape(abstract)}</p></section>
<section><h2>Verification and disclosure</h2><p>The repository provides the precise Lean theorem boundary, exact certificates, falsification controls and Tsotchke-stack execution records. The manuscript discloses substantive AI contributions. Public hosting is separate from external peer review, repository deposit and indexing.</p></section>
</article></body></html>'''
    (target / "index.html").write_text(record, encoding="utf-8")
    report = {"status": "passed", "pandoc": subprocess.check_output([args.pandoc,"--version"],text=True).splitlines()[0],
              "tectonic": subprocess.check_output([args.tectonic,"--version"],text=True).strip(),
              "files": {str(p.relative_to(ROOT)): {"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
                        for p in sorted((ROOT/"paper").glob(STEM+".*"))}}
    (ROOT/"results/paper-build.json").write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
    print(json.dumps(report,indent=2))

if __name__ == "__main__":
    main()

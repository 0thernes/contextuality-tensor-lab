# Prepared arXiv source package

The release includes `contextuality-tensor-arxiv-source.zip`: the manuscript LaTeX
source and its vector figure. The bibliography is embedded in the main source,
and fonts use standard TeX Gyre/Latin Modern packages. It was compiled with Tectonic
0.17.0 (XeLaTeX engine). Select **XeLaTeX (`xelatex`) with TeX Live 2025** in the
submission workflow; this source uses `fontspec` and `unicode-math`.

Checked against arXiv's [current TeX Live and processor documentation](https://info.arxiv.org/help/faq/texlive.html)
on 9 November 2026 (America/Los_Angeles): XeLaTeX is supported, TeX Live 2025 is
the default, and OpenType fonts must be selected by file name rather than a
registered system font name. The frozen source already uses file-based TeX Gyre
and Latin Modern font selections. The prior isolated Tectonic build verifies the
bundle locally; it is not a receipt from arXiv's own compiler. Inspect the PDF
produced by arXiv during the actual submission before finalizing it.

Suggested category: quant-ph. Title and abstract must match the final public PDF.
The source package is preparation, not an arXiv submission or identifier.

The registered author must review the output and make the applicable submission,
endorsement and licensing declarations. The present custom verification license
does not silently grant a new Creative Commons license. arXiv's nonexclusive
distribution license can be selected by the author if appropriate.

# Public-site artifact verification

Status: **PASS**. Checked anonymously over HTTP at 2026-11-10T03:50:24.793091+00:00.

Published source: `de48ed9002e930825f1cf5f140c8dc8cbfdc1ea0`. All comparisons use bytes returned by `git show de48ed9002e930825f1cf5f140c8dc8cbfdc1ea0:docs/PATH`, not the working tree or its line endings.

**18 of 18 tracked docs files** were served byte-for-byte identically. All 16 public-content files were checked. Repository control files are reported separately; missing control files do not hide a missing runtime, paper, or evidence asset.

| Asset | HTTP | Bytes | Exact Git match |
| --- | ---: | ---: | --- |
| `docs/.nojekyll` | 200 | 0 | yes |
| `docs/app.js` | 200 | 7899 | yes |
| `docs/index.html` | 200 | 9937 | yes |
| `docs/lab.mjs` | 200 | 3191 | yes |
| `docs/moonlab_live.mjs` | 200 | 4673 | yes |
| `docs/paper/contextuality-tensor.md` | 200 | 23454 | yes |
| `docs/paper/contextuality-tensor.pdf` | 200 | 100256 | yes |
| `docs/paper/contextuality-tensor.tex` | 200 | 27017 | yes |
| `docs/paper/index.html` | 200 | 3489 | yes |
| `docs/results/stack_report.json` | 200 | 12370 | yes |
| `docs/style.css` | 200 | 10647 | yes |
| `docs/vendor/.gitattributes` | 200 | 8 | yes |
| `docs/vendor/NOTICE.md` | 200 | 1169 | yes |
| `docs/vendor/moonlab/LICENSE` | 200 | 1091 | yes |
| `docs/vendor/moonlab/PROVENANCE.md` | 200 | 1683 | yes |
| `docs/vendor/moonlab/moonlab.js` | 200 | 283439 | yes |
| `docs/vendor/moonlab/moonlab.wasm` | 200 | 1484413 | yes |
| `docs/worker.mjs` | 200 | 239 | yes |

## Paper and scholarly metadata

The served PDF has **8 pages** and SHA-256 `2d0f0d2af4177a48d5691286b470b7b14d709646e1d1c4874ce04795408e8b6f`.

PDF title metadata: Exact contextuality degrees for disjoint Mermin configurations

The publication landing page contains the required title, author, publication-date and PDF-link citation meta tags: **True**. These are crawlability metadata; no Google Scholar indexing is inferred.

- `citation_title`: Exact contextuality degrees for disjoint Mermin configurations
- `citation_author`: Donahue, Alexander S.
- `citation_publication_date`: 2026/11/09
- `citation_technical_report_institution`: 0thernes LLC
- `citation_pdf_url`: https://0thernes.github.io/contextuality-tensor-lab/paper/contextuality-tensor.pdf

## License, provenance and limits

The served Moonlab license and provenance files match the pinned Git bytes. MIT grant present: **True**; upstream commit recorded: **True**; browser sampler and CPU-simulation disclosures present: **True**.

Non-200 paths: none.

This audit verifies public artifact delivery and selected metadata. It does not replace formal-proof checking, browser execution testing, journal peer review or scholarly-index verification. No remote state was changed.

## Directory URLs and metadata consistency

- `https://0thernes.github.io/contextuality-tensor-lab/` returned HTTP 200 and matches `docs/index.html` byte-for-byte: **True**.
- `https://0thernes.github.io/contextuality-tensor-lab/paper/` returned HTTP 200 and matches `docs/paper/index.html` byte-for-byte: **True**.

The citation title equals the PDF title metadata: **True**. The citation PDF URL points to the verified PDF asset: **True**.

# Contextuality Tensor Lab

**An exact degree formula, a Lean 4 proof, and a working four-qubit experiment.**

[Run the live lab](https://0thernes.github.io/contextuality-tensor-lab/) ·
[Read the paper](https://0thernes.github.io/contextuality-tensor-lab/paper/) ·
[Formal verification boundary](lean/README.md) · [Publication status](publication/STATUS.md)

For full context families made from `k` disjoint copies of the Peres–Mermin square,
the exact minimum number of violated contexts is

```math
d_k=\frac{7^k-5^k}{2}.
```

For `k` Mermin pentagrams it is `(6^k-4^k)/2`. The normalized gap `2d/L` tends to one.
These formulas answer the repeated-disjoint-copy question posed in Section 6 of
[Muller and Saniga, arXiv:2609.19862v1](https://arxiv.org/html/2609.19862v1).
The proof uses the exact identity `1 + score = product(1 + local score)` and
an attaining assignment. It is not a numerical extrapolation.

The contexts include **every nonempty union of one local context or an empty choice
from each block**. The observable vertices remain disjoint. This is different
from keeping only the six or five original contexts per copy.

| Family | Copies | Qubits | Contexts | Sharp classical score | Degree |
|---|---:|---:|---:|---:|---:|
| Square | 1 | 2 | 6 | 4 | 1 |
| Square | 2 | 4 | 48 | 24 | 12 |
| Square | 3 | 6 | 342 | 124 | 109 |
| Square | 4 | 8 | 2400 | 624 | 888 |
| Pentagram | 1 | 3 | 5 | 3 | 1 |
| Pentagram | 3 | 9 | 215 | 63 | 76 |
| Pentagram | 4 | 12 | 1295 | 255 | 520 |

The finite two- and three-copy values were already reported in the source paper.
The contribution under review is the arbitrary-copy result, with exact proof and
execution artifacts. A bounded search found no duplicate of these degree formulas;
historical priority and journal acceptance are not established. This is an
AI-assisted research preprint, not external peer review or a statistical meta-analysis.

## What runs

The live browser lab lets you change all 18 classical values, inspect 48 contexts,
enumerate all 262,144 assignments, inject an incorrect operator sign, run actual
Moonlab WASM measurements, and explore arbitrary-copy counts and readout noise.

The native pipeline executes all four requested Tsotchke components:

* **Moonlab:** native four-qubit gates and sequential Pauli measurements; 9,472/9,472
  recorded context shots satisfied the operator identities.
* **quantum_rng:** actual seeded software mixer for context selection and measurement
  draws. It is classical software, not hardware quantum entropy.
* **QGTL:** actual Fubini–Study and Berry-curvature C kernels checked against analytic
  and independently computed geometry of Moonlab-prepared states.
* **Eshkol:** independent exact enumeration of the square and two-square assignments,
  recovering maximum score 24, degree 12 and 9,216 optimizers.

Moonlab is a classical simulator. State independence follows from exact matrix
identities; finite shots test the implementation. The browser uses its own disclosed
seeded xorshift sampler. The offline pipeline uses Tsotchke quantum_rng.

## Reproduce

Python 3.9+ and Node are sufficient for the independent finite checks:

```text
python scripts/verify_exact.py
python -m unittest discover -s tests -v
node tests/demo.test.mjs
```

For the complete native stack, install NumPy, GCC, Node and Eshkol, ensure
`eshkol-run` is on PATH or set `ESHKOL_RUN` to its executable, then run:

```text
python scripts/run_stack.py
```

All four components are required; a missing component is a failure. See
[the stack adapter notes](src/stack_README.md) for the pinned binary layout and
platform-specific toolchain settings.

For Lean, install elan and use the pinned toolchain/dependencies:

```text
cd lean
lake exe cache get
lake build
lake env lean Verification.lean
```

The kernel evaluates the finite certificates; no `sorry`, added axioms or
`native_decide` is used. See [the formal README](lean/README.md) and the generated
axiom audit for the exact end-to-end theorem boundary.

Serve `docs/` over HTTP to run the live app. The native browser test requires
Playwright; [its source](tests/browser.test.mjs) documents module/browser options.

## Noise matters

The ideal gap approaches one, but that number is a context-correlator deficit.
Under independent flips of individual outcomes, the inequality's readout thresholds
are **6.32097676% for squares and 5.99441316% for pentagrams**, independent of copy
count. At any fixed positive flip probability the normalized noisy margin eventually
approaches zero. The paper and live plot make that distinction explicit.

This result does not shrink the 31-ray three-dimensional KS construction or settle
the SIC conjecture. The number of qubits grows with the number of copies.

## Evidence map

| Artifact | Purpose |
|---|---|
| [Exact certificate](results/exact-certificate.json) | Integer enumeration, full-support tests and adversarial controls |
| [Four-qubit configuration](results/four-qubit-square.json) | All 18 Pauli words, 48 contexts and signs |
| [Stack report](results/stack_report.json) | Actual Moonlab/QRNG/QGTL/Eshkol executions and source hashes |
| [Browser report](results/stack_browser.json) | Live WASM and UI checks in desktop/mobile browser |
| [Independent implementation review](results/review.md) | Separately written matrix, support and noise checks |
| [Research audit](research/frontier-review.md) | Derivation and bounded comparison with prior work |
| [Manuscript](paper/contextuality-tensor.md) | Theorems, proofs, limitations, references and AI disclosure |

Author: Alexander S. Donahue, 0thernes LLC. See [CITATION.cff](CITATION.cff).
Project material uses the verification license in [LICENSE](LICENSE);
third-party components retain their MIT licenses and attribution.

# Independent mathematical and implementation review

Review date: 9 November 2026, America/Los_Angeles. Reviewer: a separate Codex research subagent within this project. This is an adversarial internal review, not independent human peer review.

## Outcome

No remaining mathematical discrepancy was found in the reviewed exact Python certificate, its construction of the full four-qubit two-square support, or the stated independent-outcome-flip noise formula. Six independent regression tests passed. The tests deliberately derive the operator algebra from literal matrices over Gaussian integer pairs, rather than importing the production Pauli multiplication or commutation routines.

The target fits the question in Muller and Saniga, arXiv:2609.19862v1, Section 6. Their full hypergraph support of a disjoint union includes cross-component unions of contexts. It is not the ordinary disjoint union of context lists. Definition 11 makes the independence/kernel constraints componentwise, so the context tuple parameterization used here is exact. See [primary source](https://arxiv.org/html/2609.19862v1) and the complete derivation in `research/frontier-review.md`.

## Checks performed

Command, from repository root:

```text
python -m unittest discover -s tests -p test_independent.py -v
```

Result: 6 tests passed in 4.310 seconds, process exit 0.

* Literal 2x2 I/X/Y/Z matrices are tensor multiplied using pairs of Python integers for real and imaginary parts. The test checks every commutator and every signed context product for the two-qubit square, three-qubit pentagram, and four-qubit two-square construction.
* An independent graph is derived from those literal matrix commutators. A recursive set-based enumeration of independent subsets, followed by direct even-neighbor checks, recovers precisely the declared full supports in all three cases. This differs from the production bitmask recurrence.
* Direct evaluation of all 512 square and 1024 pentagram assignments gives score multiplicities `{4:96, 0:320, -4:96}` and `{3:320, -1:640, -5:64}` respectively, matching the production routine.
* The rational quantum score at p=1/20 for two copies is reconstructed by enumerating all individual readout-flip patterns for each context size. It agrees exactly with the closed-form noise expression.
* Duplicating a context together with its sign and flipping one context sign are rejected at the intended validation checks. Invalid noise-family names are rejected.
* Importing the certificate module under optimized Python (`-O`) exits unsuccessfully, so stripped assertions cannot silently certify bad input.

The root agent's main certificate separately performs all 262144 unrestricted assignments for the four-qubit case and checks its factorization one assignment at a time. That work was inspected as source; the six independent tests above are this reviewer's own execution evidence.

## Findings fixed during review

1. Optimized Python disabled assertions in the original validator. The root agent added a module-level rejection of optimized execution. The negative test now passes.
2. An unknown name in `noisy_quantum_score` originally selected the pentagram branch silently. It now raises `ValueError`.
3. The first duplicate-context negative control mismatched the context/sign list lengths. It was changed to append the matching sign too, so the intended duplicate-context check is exercised.

## Mathematical and physical limits

The exact classical optimizer is established by an upper bound on the absolute augmented seed score and an attaining positive seed assignment. Negative score endpoints are accounted for. The source's k=2 and k=3 values are recovered; those finite values are prior work. The claim of interest is the exact all-copy expression and the matching limit question, with bounded-search novelty qualifications.

The initial `ContextualityTensor.lean` source inspected in this review defines actual finite context choices and signed residuals, derives their finite-sum factorization, universally quantifies over every component assignment, and provides explicit all-positive witnesses. It is not merely a power formula defined by fiat. Lean compilation and axiom-audit evidence must be reported separately by the formalization runner. The graph-support identification and the arbitrary-tensor Pauli realization should not be called kernel-checked unless corresponding declarations are actually supplied; they are supported here by the analytic proof and independent finite matrix checks.

epsilon is a deficit in signed context correlators. Under independent outcome flips, the square/pentagram thresholds are approximately 0.0632098 and 0.0599441 and do not increase with copy count. At the threshold there is equality, not strict violation. Arbitrarily large epsilon therefore does not establish arbitrarily noisy hardware tolerance, a loophole-free experiment, quantum hardware execution, or quantum advantage. The available Tsotchke state-vector execution remains a classical simulation.

## Reviewed file hashes

SHA-256 at the review snapshot; later edits require reassessment where relevant:

```text
src/certificates.py
8350D42C2DCEB5E82D36017EF0698CA3272C0483F0F5B90101444869B5DA2D22
scripts/verify_exact.py
721C2F8FE23EE4A049998B5FD7EFFE16FE820B4D44DD910E550F2DA3FB8C0B03
tests/test_independent.py
9656A95DDCA2FF5E0A90774B3C77994EDAA107D7407DE59D8A72556A22371479
```

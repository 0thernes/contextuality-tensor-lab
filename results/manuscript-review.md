# Internal technical manuscript review

Reviewed 9 November 2026. Reviewer: a separate AI agent, not an external human referee. The manuscript was read against the source question, exact derivation, executable records, independent tests and current Lean source. This is a bounded technical review, not a priority certificate or journal recommendation.

## Result

No mathematical counterexample or material numerical mismatch was found. The product identity, sign-aware endpoint reduction, all-copy square and pentagram formulas, mixed formula and arbitrary contextual-seed limiting argument are valid under the stated disjoint-vertex/full-union hypotheses. The elementary outcome-flip calculation correctly identifies fixed thresholds as the copy count grows. The manuscript carefully distinguishes the source question from smaller KS ray sets, SICs, mutually unbiased bases, computational speedup and unrestricted noise robustness.

The argument is an elementary exact solution to a specifically stated question in the inspected source. That supports the scoped contribution claim; it does not establish worldwide historical priority. Nearby contextual-fraction tensor laws and quantum XOR repetition are relevant comparisons and do not directly subsume the specific contextuality-degree calculation. The primary source's finite two- and three-copy examples were already known, and the manuscript accurately says so.

## Recommended edits before freezing the manuscript

1. Cite the original square/pentagram literature in the text at the seed definitions, rather than leaving references 4 and 5 only in the bibliography. Reference 6 should be cited where a general framework is used, or omitted if unnecessary. Add references 7–11 to the corresponding stack and formalization paragraphs.
2. Add the published XOR article's DOI, `10.1007/s00037-008-0250-4`. The author-hosted published PDF verifies the title, journal, volume, pages and DOI. The arXiv record uses an earlier title, which is not an error in the manuscript's published title.
3. Section 7.2 should explicitly list the square and pentagram limit theorems already proved in `Asymptotics.lean`, and should identify actual tagged-vertex context uniqueness and response transport from `UnionModel.lean`. These are substantive parts of the formal result.
4. After `Support.lean` is included and its build/axiom audit recorded, remove equation (4) from the wholly-unformalized list. The general support theorem starts from arbitrary subsets and the block diagonal adjacency operator; it does not define the desired global support to be a product. It does not by itself identify the seed's literal Pauli anticommutation graph with its six/five enumerated seed contexts; that seed identification is still established by executable exhaustive checks and the manuscript.
5. Claim the completed matrix build only after its actual success. `Pauli.lean` currently gives explicit integral square identities, within-seed commutation, cross-register commutation, four-qubit products, distinct/nonidentity observables and a complex-cast product identity. The arbitrary-copy tensor realization and the pentagram's physical matrices remain analytic/executable unless additional declarations are added.
6. Keep the precise missing formal results explicit: general-seed Theorem 5, heterogeneous endpoint Theorem 2, mixed-family degree formula, arbitrary-register quantum realization and the readout-noise theorem. The exact square/pentagram limits are formal, which is different from formalizing every contextual seed.
7. The human-review/publication statement must also cover Zenodo, whose current depositor AI policy requires a human research basis and accountability. Direction plus automated checking alone does not establish that condition. See the updated `research/publication-routes.md`. No human review should be asserted as completed without evidence.

## Numerical audit

The source data and saved logs agree with the manuscript:

| Claim | Independently checked evidence |
|---|---|
| Square score multiplicities | 512 assignments, `4:96, 0:320, -4:96` |
| Pentagram score multiplicities | 1024 assignments, `3:320, -1:640, -5:64` |
| Four-qubit full support | 18 observables; 48 contexts; 12 size-three and 36 size-six |
| Four-qubit optimum | 262144 assignments; maximum 24; degree 12; 9216 attaining assignments |
| Moonlab finite context trials | 5376, including a 16-component mixed-state ensemble |
| Additional seeded context sampling | 4096 trials; 4096 parity agreements |
| Native projective measurements | 50484 |
| Maximum Pauli-oracle discrepancy | 5.551115123125783e-16, below manuscript bound 5.56e-16 |
| Wrong context-sign rejection | All 5376 deliberately wrong predictions rejected |
| QGTL maximum analytic error | 1.1219247753047057e-11, below manuscript bound 1.2e-11 |
| Eshkol output | The same seed histogram, maximum 24, minimum 12 and 9216 minimizers |

The simulator, software entropy source and geometry check are described accurately. Sampling is an implementation check; state independence follows from operator products. The QGTL calculation is an adapter/geometry check, not a logical premise of the contextuality degree theorem. The larger spectra use exact convolution, correctly distinguished from exhaustive global assignment searches.

## Formal proof audit

`ContextualityTensor.lean` defines and sums actual residual values over nonempty optional-context tuples. It proves the sum/product identity, connects that score to the actual count of negative residuals, proves local assignment bounds, supplies an attaining all-positive assignment, and concludes arbitrary-copy sharp lower bounds and exact minima. Finite `decide`/`decide +kernel` checks are kernel proof terms, not external oracle claims. No `sorry` was observed.

`UnionModel.lean` proves injectivity and nonemptiness of the actual tagged-vertex unions from the seed hypotheses, counts their images and transports the residual to unrestricted values assigned to tagged vertices. Therefore it does not assume unmotivated factorizability of values of newly introduced observables: no such extra observables are introduced.

`ActualModel.lean`, inspected after the initial review, further defines signs, scores and violation counts directly on the image family of actual vertex subsets. It proves their equality to the tuple-based quantities, obtains exact minimum statements quantified over unrestricted assignments to the tagged vertices, and transports both epsilon limits. This closes the explicit end-to-end combinatorial statement; the remaining qualification is identification with each literal Pauli anticommutation graph, as noted above.

`Asymptotics.lean` proves a general ratio-of-powers limit, specializes it to both families and equates the displayed epsilon formulas to twice the actual attaining violation count divided by the context count. Its division-by-zero convention at copy count zero is harmless for an at-infinity limit; the manuscript's scientific statements use positive copy counts.

`Support.lean` proves the arbitrary-subset block adjacency kernel identity, independence equivalence, full support product equivalence, and exclusion of precisely the all-empty tuple. It permits block-dependent matrices on a common finite vertex type, so its graph hypotheses are more general than repeated identical seeds. No symmetry assumption is needed for this algebraic decomposition; ordinary simple anticommutation graphs are a special case.

The files must be tested together and audited in the final frozen release. A successful proof build verifies its propositions; it does not verify the input literature metadata, research priority, all floating-point software, human authorship declarations or publication status.

## Primary reference checks

* Muller–Saniga: inspected [arXiv HTML v1](https://arxiv.org/html/2609.19862v1), especially Definitions 11–13, the disjoint-union construction and the Section 6 limit question. The source's definition of normalized gap matches the one used here. A strict experimental violation needs a strict correlator bound, correctly stated by this manuscript.
* Contextual fraction: [arXiv:1705.07918](https://arxiv.org/abs/1705.07918), PRL 119, 050504, DOI `10.1103/PhysRevLett.119.050504`. Theorem 2's tensor law concerns contextual fraction, not this degree normalization.
* Cleve–Slofstra–Unger–Upadhyay: the [author-hosted published article](https://cs.uwaterloo.ca/~cleve/pubs/2008PerfectParallelRep.pdf) verifies the published title, Computational Complexity 17 (2008), 282–299, DOI `10.1007/s00037-008-0250-4`.
* Mermin: [publisher record](https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.65.3373) verifies PRL 65, 3373–3376 and DOI `10.1103/PhysRevLett.65.3373`.
* Peres: title, pages and DOI `10.1016/0375-9601(90)90172-K` are consistent across records. Direct publisher fetching was unavailable during this audit, so no new technical claim was derived from an unread full text. The seed identities themselves are checked exactly.
* Abramsky–Brandenburger: [author arXiv record](https://arxiv.org/abs/1102.0264) verifies NJP 13 (2011), 113036; the DOI is `10.1088/1367-2630/13/11/113036`.

The bounded search found no duplicate of these exact all-copy degree formulas. That is a search result, not proof of novelty.

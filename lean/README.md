# Formal verification boundary

The project uses Lean 4.35.0 and mathlib v4.35.0. The exact mathlib commit and
transitive dependencies are pinned in `lake-manifest.json`.

```text
lake exe cache get
lake build
lake env lean Verification.lean
python audit_axioms.py
```

`Verification.lean` prints selected theorem statements and discovers every
imported theorem declaration under `ContextualityTensor` for an exhaustive
axiom audit. It fails if any theorem uses an axiom other than `propext`,
`Classical.choice`, or `Quot.sound`. The Python wrapper stores the complete
audit and source hashes in `results/lean-axioms.log` and
`results/lean-axioms.json`. The proofs contain no `sorry`, added axioms, or `native_decide`.
Finite exhaustive certificates use `decide +kernel`, so their Boolean
evaluations are reduced by Lean's kernel.

## What is proved

* `ContextualityTensor.lean` defines a completely unrestricted deterministic
  assignment on each block, signed context responses, nonempty context-choice
  tuples, their score, and the number of negative responses. It proves that
  score plus one is the product of the augmented local scores and that score
  equals context count minus twice the violation count. The local square and
  pentagram certificates range over all 512 and 1,024 local assignments.
* `square_minimum_closed_form` proves, for every natural `k`, both existence of
  an assignment with `(7^k - 5^k)/2` violations and that every assignment has
  at least this many. `pentagram_minimum_closed_form` proves the corresponding
  `(6^k - 4^k)/2` statement. Natural-number division is exact here; the proofs
  establish the stronger doubled-degree identities first.
* `ContextualityTensor/UnionModel.lean` constructs the actual context as a
  finite set of tagged vertices in disjoint blocks. It proves that distinct
  context-choice tuples give distinct actual contexts, that nonempty choices
  give nonempty contexts, and that the score response equals the product of
  the values assigned to these actual vertices, multiplied by the context
  sign. Thus the counts are not counts with multiplicity, and no hidden
  factorization assumption on additional observable variables is imposed.
* `ContextualityTensor/Asymptotics.lean` proves that the exact count ratios
  `(7^k-5^k)/(7^k-1)` and `(6^k-4^k)/(6^k-1)` tend to one. It identifies these
  formulas with twice the certified minimum violation count divided by the
  actual number of indexed contexts. The empty `k=0` family is permitted
  algebraically; physical contextuality statements use `k >= 1`.
* `ContextualityTensor/Pauli.lean` contains the separate explicit matrix
  realization and four-qubit operator checks. Its theorem statements specify
  exactly which operator identities are formalized.
* `ContextualityTensor/ActualModel.lean` defines signs, scores, and violation
  counts directly on the distinct actual vertex-subset contexts. It proves
  equivalence with the tuple-indexed optimization. The main statements
  `global_actual_square_minimum` and `global_actual_pentagram_minimum` quantify
  over unrestricted values assigned to actual tagged vertices. It also proves
  that the actual context-count epsilon parameters tend to one.
* `ContextualityTensor/PhysicalBridge.lean` identifies the actual four-qubit
  vertex lists with the lists of explicit matrices, and proves that their
  quantum scalar signs equal the signs used in the actual-context optimization.
* `ContextualityTensor/Support.lean` proves the graph support decomposition
  from independence and adjacency-kernel equations of an arbitrary block
  adjacency matrix, starting with arbitrary global vertex subsets.

The combinatorial and asymptotic results apply to arbitrary `k`. The Lean
development does not claim to formalize all of the source paper's graph
terminology, identification of each seed's full graph support, or the full
arbitrary-register tensor-operator construction. The
paper supplies those mathematical bridges and the executable checker verifies
the concrete four-qubit experiment independently. Literature priority,
publication status, simulator correctness, and physical hardware behavior are
not Lean theorems.

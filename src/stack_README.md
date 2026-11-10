# Live stack experiment

Run `python scripts/run_stack.py` from the repository root. GCC, Node, NumPy and
Eshkol are required. Set `ESHKOL_RUN` if `eshkol-run` is not on PATH. The runner
returns nonzero on a failed build, missing component or failed assertion. Its
report is `results/stack_report.json`; raw stage output is `results/stack_*.log`.

The four-qubit observables are two disjoint copies of this square:

```
XI IX XX
IZ ZI ZZ
XZ ZX YY
```

All rows have product `+I`. The first two columns have product `+I` and the last
column has product `-I`. In each block choose no context or one of its six local
contexts; omit the empty/empty choice. The 48 resulting contexts comprise 12
three-observable contexts and 36 six-observable contexts. There are 18 distinct
observables. These are listed contexts of compatible observables, not a claim
that every context is maximal or that all compatible subsets are included.

The native Moonlab simulator prepares zero, plus, GHZ, Bell pairs crossing the
square partition and a seeded complex state. It also tests every component of
the uniform computational-basis ensemble representing `I/16`. Pauli-basis
rotations turn each string into a native single-qubit Z measurement; Moonlab
executes the gates, draw and collapse. Operators in a context are measured in
random permutations, so the tests do not depend on one fixed compatible order.
The adapter's expectation values are compared to a separate direct complex
Pauli calculation. A repeated-measurement check tests collapse consistency.

The same Moonlab instance prepares a continuous family: four local `Ry(theta)`
then `Rz(phi)` rotations followed by three fixed CNOTs. Central differences of
its amplitudes supply derivatives to the actual QGTL C kernels. A fixed unitary
preserves the product-state Fubini–Study metric, giving diagonal entries `1/4`
for theta and `sin(theta)^2/4` for phi. With the explicitly used curvature
convention `F=-2 Im Q`, the theta/phi entries are `-sin(theta)/2`. Independent
inner products, analytic values and phase-gauge changes are checked. An
incorrect Berry sign is a deliberate rejected control.

The actual quantum_rng implementation supplies bytes for context selection,
context-order shuffles, preparation parameters and projective draws. Integer
context choices use rejection sampling to remove modulo bias. Same-build seed
replay and a changed-seed difference are verified. This does not certify
entropy quality or cryptographic unpredictability.

Eshkol separately evaluates all 512 assignments to the nine local observables,
then all 262144 ordered pairs of assignments. Its three local scores are
`-4,0,4`, with multiplicities `96,320,96`. Direct enumeration of
`(1+scoreA)*(1+scoreB)-1` attains 24 and gives 12 violated contexts, with 9216
minimizers. The independent certificate verifier and Lean development carry
their own proof obligations; Eshkol is an independent integer cross-check.

These finite simulations test the implementation. The exact signed operator
identity for each context implies ideal state independence, including mixed
states. Simulation alone cannot establish that universal claim, rule out
experimental loopholes or certify behavior of real hardware. Flipping the
predicted context sign is rejected in every exhaustive-context simulation shot.

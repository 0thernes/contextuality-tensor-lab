# Frontier review and mathematical audit

Date: 9 November 2026 (user's America/Los_Angeles date).
Prepared by a Codex research subagent as internal research documentation. This is an independent derivation and literature comparison within the same AI-assisted project, not external peer review. No claim below depends on a numerical eigensolver.

## Selected problem and boundary

Muller and Saniga, *Automated search for highly contextual Kochen–Specker proofs*, arXiv:2609.19862v1 (17 September 2026), Section 6, explicitly leave the limiting tolerated error for repeated disjoint copies of their small configurations open. Their Section 4.2 gives the context-count product, and Table 2 supplies finite comparison values. The source was read directly at [the primary full text](https://arxiv.org/html/2609.19862v1).

The target is the exact contextuality degree of these full-support disjoint unions, and their asymptotic correlator deficit. This is distinct from the earlier Hoggar lab's asymptotic full-Pauli-line theorem. It is also distinct from reducing the 31-ray three-dimensional KS construction, resolving the SIC conjecture, or resolving four MUBs in dimension six. None of those stronger claims follows here.

The derivation below answers the stated disjoint-copy question for every finite contextual seed under the specified construction. Exact formulas are available for squares and pentagrams. Its algebraic mechanism is elementary distributivity, not a new general principle about quantum computation.

## 1. Definitions and exact context bijection

Let the finite vertex sets V_i be pairwise disjoint. A signed configuration has a set H_i of distinct nonempty subsets of V_i and a sign s_i(h) in {−1,+1} for each context. Adjoin a formal empty context, with sign +1. Define the combined family by taking every union h = union_i h_i, with h_i in H_i union {empty}, except the all-empty tuple. Give h the product of its component signs.

This parameterization is injective: intersection with V_i recovers h_i. It is surjective by construction. Consequently, if m_i = |H_i|, then the number of combined contexts is

    L = product_i (m_i + 1) − 1.

For the particular full hypergraph support HS(G) of Muller–Saniga Definition 11, the construction is exactly HS(disjoint_union_i G_i). A subset h is in HS(G) precisely when it is nonempty, is independent in G, and its incidence vector is in the kernel of the adjacency matrix over F_2. With a block-diagonal adjacency matrix, independence and every kernel equation hold precisely when they hold on each component h intersect V_i. Empty component intersections satisfy both conditions. This proves both directions and excludes missing cross-component contexts.

For Pauli realizations, place each seed on its own tensor register. Distinct nonidentity seed observables remain distinct, and observables from different registers commute. A product in a combined context equals

    tensor_i (product_{v in h_i} P_v) = (product_i s_i(h_i)) I.

No interchange of anticommuting factors occurs across registers. Thus the assigned context sign is the actual operator sign. The scalar identity holds on every quantum state, including states entangled between registers; a product-state assumption is not needed for the ideal state-independent claim.

The square uses two qubits per copy and the pentagram three. In particular two square copies yield a concrete four-qubit configuration. Increasing copy count increases the number of qubits and the maximum context size. One must not advertise the arbitrary-copy limit as a fixed-four-qubit result.

## 2. Exact score factorization

For a deterministic classical assignment a_i: V_i -> {−1,+1}, write

    q_i(h) = s_i(h) product_{v in h} a_i(v),
    beta_i(a_i) = sum_{h in H_i} q_i(h),
    q_i(empty) = 1.

Every global deterministic assignment is uniquely a tuple of component assignments. Shared classical randomness does not enlarge the maximum of a linear inequality: each randomized model is a convex mixture of such deterministic assignments. Expanding a product of finite sums gives the exact identity

    1 + beta_combined(a) = product_i (1 + beta_i(a_i)).       (1)

The left side includes the all-empty tuple once. It must be subtracted once when reporting the actual inequality. Leaving out that subtraction changes both the count and the score.

If B is the maximum classical score, the contextuality degree is d = (L−B)/2. This is an integer because the score is the number of satisfied contexts minus the number violated. The quantum score is L.

## 3. Exact optimization from two endpoints

Let ell_i and u_i be the minimum and maximum of the augmented score 1+beta_i over all assignments. Both extrema are attained because the assignment set is finite. Equation (1) gives

    B + 1 = max { product_i z_i : z_i in {ell_i,u_i} }.       (2)

Proof: the product is a multilinear function on the real box product_i [ell_i,u_i]. Keeping all other variables fixed, a linear function of one coordinate has its maximum at an endpoint. Iterating puts a maximum at a corner. Every corner is realized by independent component assignments, so relaxation to intervals loses nothing.

Equation (2) also gives an O(k) computation of the exact extrema. Starting with [lo,hi]=[1,1], replace the endpoints by the minimum and maximum of the four products lo*ell_i, lo*u_i, hi*ell_i, hi*u_i. This endpoint recurrence works for heterogeneous seeds and arbitrary signs. It does not assume that all intermediate scores between the endpoints are attainable.

For k identical seeds with endpoints ell and u, u >= 1: the average of beta over uniformly random independent vertex values is zero because all contexts are nonempty. If u >= |ell|, then B_k+1 = u^k. If ell < −u, then B_k+1 = |ell|^k for even k and u*|ell|^(k−1) for odd k. The parity clause matters; multiplying only the maximum scores is not valid for an arbitrary signed seed.

## 4. Exact square family

Use the following standard two-qubit square (each row and column is a context):

    XI  IX  XX
    IZ  ZI  ZZ
    XZ  ZX  YY

Five context products are +I; the third column has product −I. Each observable occurs twice. The product of the six signed residuals q(h) is therefore −1 for every classical assignment. The number of violated contexts is odd, hence is 1, 3, or 5, and beta lies in {4,0,−4}. The all-positive vertex assignment has beta=4. Therefore the augmented scores lie in {5,1,−3}, with positive maximum absolute value 5 attained.

For every k >= 1:

    observables = 9k, qubits = 2k,
    L_k = 7^k − 1,
    B_k = 5^k − 1,
    d_k = (7^k − 5^k)/2,
    epsilon_k = (7^k − 5^k)/(7^k − 1) -> 1.

The exact lower bound follows from |1+beta| <= 5 and (1). The upper bound on d is attained by choosing the all-positive assignment in every copy. This gives an explicit optimizer at every k; it does not require a SAT search at growing k.

Independent finite enumeration performed during this review used the one-qubit Pauli multiplication table, enumerated all 511 nonempty vertex subsets, imposed the independent/kernel tests, and then enumerated all 512 assignments. It recovered exactly the six displayed contexts and the score multiplicities {4:96, 0:320, −4:96}.

## 5. Exact pentagram family

The ten observables are XII, IXI, IIX, IYI, IIY, YII, XXX, XYY, YXY, YYX. The five contexts are:

    XII IXI IIX XXX      (+)
    XII IYI IIY XYY      (+)
    YII IXI IIY YXY      (+)
    YII IYI IIX YYX      (+)
    XXX XYY YXY YYX      (−)

Again every observable occurs twice. The number of violated contexts is odd, so beta lies in {3,−1,−5}. Thus 1+beta lies in {4,0,−4}; the all-positive assignment attains 4. For k >= 1:

    observables = 10k, qubits = 3k,
    L_k = 6^k − 1,
    B_k = 4^k − 1,
    d_k = (6^k − 4^k)/2,
    epsilon_k = (6^k − 4^k)/(6^k − 1) -> 1.

Independent enumeration over all 1023 nonempty vertex subsets and all 1024 vertex assignments recovered exactly these five contexts and score multiplicities {3:320, −1:640, −5:64}.

For a mixture of s squares and p pentagrams, the exact formulas are L=7^s 6^p−1, B=5^s 4^p−1, and d=(7^s 6^p−5^s 4^p)/2. The physical tensor realization has 2s+3p qubits. Positive maximizers attain the bound in every factor.

## 6. Universal contextual-seed limit

Let a finite contextual seed have m nonempty contexts. Every assignment violates at least one, so −m <= beta <= m−2. Therefore

    |1+beta| <= m−1.

For k copies, (1) yields B_k <= (m−1)^k−1. On the other hand B_k >= 0 by averaging over all vertex assignments, since each nonempty context residual has mean zero. Thus

    0 <= B_k / ((m+1)^k−1)
      <= ((m−1)^k−1)/((m+1)^k−1) -> 0.

It follows that epsilon_k = 1−B_k/L_k tends to 1. This proof needs no exact seed degree, Pauli representation, SAT certificate, or assumption that positive augmented scores dominate. A contextual seed necessarily has m >= 2 because the zero-mean argument implies B >= 0 and B <= m−2.

The context count grows exponentially. The limiting statement concerns a particular full family of contexts, not the same finite test repeated with its original six or five context types. The conventional contextuality degree of a disjoint union containing only original component contexts would instead be additive; that is a different construction.

## 7. Physical error interpretation and falsifiable noise prediction

epsilon = 2d/L is the tolerated deficit of a signed context correlator from its ideal value. It is not the probability of a flipped gate or individual readout. If every signed correlator is greater than 1−epsilon, the inequality is violated. At equality the classical bound is reached, so strict inequality is needed for a strict violation.

For a concrete noise model, independently flip each measured observable outcome with probability p in [0,1/2]. Let eta=1−2p. A context of r*j observable outcomes then has signed mean eta^(r*j). If the seed has m contexts all of size r, the exact quantum expectation summed over the combined context family is

    Q_k(p) = (1 + m*eta^r)^k − 1.                         (3)

This follows by the same expansion and is a prediction for the specified independent readout-noise model only. It assumes flips per measurement occurrence, independently across outcomes and registers. Compatibility errors, correlated readout, state-preparation errors, and invasive measurement are different models.

For squares, (3) exceeds the exact B_k precisely when

    p < (1 − (2/3)^(1/3))/2 = 0.0632097676... .

For pentagrams, the condition is

    p < (1 − (3/5)^(1/4))/2 = 0.0599441316... .

These thresholds are independent of k. Therefore epsilon_k -> 1 does not imply tolerance of arbitrarily faulty elementary measurements. At a fixed nonzero p, even when below threshold, the normalized margin (Q_k−B_k)/L_k tends to zero because both relevant bases are smaller than m+1. Statistical evidence then needs increasing precision. This is an essential limit on an experimental interpretation, not a defect in the exact degree theorem.

A suitable simulation control compares empirical noisy scores with (3), tests points on both sides of the threshold, and identifies the noise model explicitly. A score output fixed to the desired sign without executing measurements is not a state-vector experiment.

## 8. Literature comparison and novelty limits

The finite base constructions, the definition of contextuality degree, and product-based ideas are established. The focused searches on 9 November 2026 used combinations of contextuality degree, disjoint union, multiplicative, augmented score, product, square, pentagram, and the displayed exponential bases. No primary source duplicating the specific augmented-score endpoint formula or these all-copy exact degrees was located. This is a bounded search, not proof of priority. The arXiv version inspected explicitly poses the matching limit question; subsequent unpublished solutions remain possible.

The following nearby prior results must be distinguished:

* Abramsky, Barbosa and Mansfield, *The contextual fraction as a measure of contextuality*, PRL 119, 050504 (2017), Theorem 2, prove CF(e tensor e') = CF(e)+CF(e')−CF(e)CF(e'). The theorem and supplementary proof were read in the [accepted author manuscript](https://www.pure.ed.ac.uk/ws/portalfiles/portal/40799909/contextual_fraction_revision2_both_1.pdf); [primary arXiv record](https://arxiv.org/abs/1705.07918), [DOI](https://doi.org/10.1103/PhysRevLett.119.050504). This is already an amplification law for a different contextuality measure. Ideal KS seeds have strong contextuality (CF=1), so that law does not yield the present finite degree formulas or uniform signed-correlator epsilon. Do not claim the first contextuality amplification theorem.
* Cleve, Slofstra, Unger and Upadhyay, *Perfect Parallel Repetition Theorem for Quantum XOR Proof Systems*, Computational Complexity 17 (2008), 282–299, study entangled two-prover XOR games. Their [primary author PDF](https://cs.uwaterloo.ca/~cleve/pubs/2008PerfectParallelRep.pdf) and [arXiv record](https://arxiv.org/abs/quant-ph/0608146) explain the quantum repetition theorem and the failure of the analogous unrestricted classical statement. Here a global noncontextual assignment restricts to disjoint fixed observable alphabets; it is not an unrestricted strategy with answers depending on the full vector of repeated questions. Do not assert a general classical XOR-game repetition theorem.
* The expectation of a product of independent signs equals the product of their expectations, familiar from the piling-up lemma in linear cryptanalysis. The present finite-sum identity is the corresponding elementary algebra. Novelty, if established, lies in applying it to this explicitly posed full-HS contextuality question with exact degree and realization certificates, not in inventing bias multiplication.

The previous Hoggar repository's current C3 paper already gives an exact finite four-qubit carrier/completion spectral example and a Lean formalization. This new construction does not reproduce that certificate. The previous project's literature audit specifically warned that its full-Pauli asymptotic theorem did not answer the disjoint-graph question. The present full-HS bijection addresses that scope gap explicitly.

For the unrelated three-dimensional KS target, primary 2024 work establishes the lower bound 24 and retains the 31-ray upper construction: Li, Bright and Ganesh, *A SAT Solver + Computer Algebra Attack on the Minimum Kochen–Specker Problem*, [IJCAI primary PDF](https://www.ijcai.org/proceedings/2024/0210.pdf). This review did not find a smaller exact ray set. Recent work includes a number-field survey, [arXiv:2603.16988](https://arxiv.org/abs/2603.16988), and additional formal-certification research. No reduction of the KS minimum is claimed.

## 9. Independent review checklist for the implementation

1. The context family must include every nonempty tuple of component contexts or empties, with no duplicate union; ordinary disjoint hypergraph union is insufficient.
2. Prove or independently enumerate the seed full HS, rather than just assuming the displayed contexts exhaust it.
3. Verify each seed's actual Pauli products, commutation and tensor embedding; an abstract inconsistent sign table alone is not a quantum proof.
4. Connect the generic Lean product-score statement to explicit seed assignment scores. A recurrence merely defined to return the expected power is not this connection.
5. Include both a universal upper bound on score and an attaining assignment to establish an exact degree.
6. Distinguish kernel-checked statements from executable enumeration, analytic deductions not formalized, and simulator observations.
7. Use strict noise-threshold inequalities, specify the meaning of p, and do not infer a hardware threshold from epsilon.
8. Deliberately mutate a context sign, drop cross-component contexts, and duplicate a tuple; validators should detect these changes or produce the appropriately changed bound.
9. Any claim of firstness must remain qualified by the bounded literature search and lack of external peer review.


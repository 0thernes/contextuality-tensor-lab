import Mathlib.Data.ZMod.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod

/-!
The full-support conditions of an anticommutation graph, including the empty
set, split componentwise for an actual block diagonal adjacency matrix.
The statements start from arbitrary subsets of the global vertex alphabet;
the global support is not defined to be a product of local supports.

Adjacency is encoded in ZMod 2. For a graph, a matrix entry is 1 precisely on
an edge. The proof also works for arbitrary square matrices over ZMod 2.
-/

namespace ContextualityTensor

open Finset

variable {I V : Type*} [Fintype I] [Fintype V] [DecidableEq I] [DecidableEq V]

/-- Independence plus the adjacency-kernel condition; the empty set is allowed. -/
def graphSupportWithEmpty {W : Type*} [Fintype W] [DecidableEq W]
    (A : W → W → ZMod 2) (s : Finset W) : Prop :=
  (∀ u ∈ s, ∀ v ∈ s, A u v = 0) ∧
  (∀ u, ∑ v : W, (if v ∈ s then A u v else 0) = 0)

/-- Adjacency matrix of disjoint graphs on tagged vertex sets. -/
def blockAdjacency (A : I → V → V → ZMod 2) (u v : I × V) : ZMod 2 :=
  if u.1 = v.1 then A u.1 u.2 v.2 else 0

/-- The vertices of an arbitrary global subset that lie in one block. -/
def supportFiber (s : Finset (I × V)) (i : I) : Finset V :=
  univ.filter fun v => (i, v) ∈ s

omit [Fintype I] in
@[simp] theorem mem_supportFiber (s : Finset (I × V)) (i : I) (v : V) :
    v ∈ supportFiber s i ↔ (i, v) ∈ s := by simp [supportFiber]

theorem block_kernel_sum (A : I → V → V → ZMod 2)
    (s : Finset (I × V)) (i : I) (u : V) :
    (∑ v : I × V, if v ∈ s then blockAdjacency A (i, u) v else 0) =
      ∑ v : V, if v ∈ supportFiber s i then A i u v else 0 := by
  rw [Fintype.sum_prod_type]
  simp only [blockAdjacency, mem_supportFiber]
  have hf : (fun j : I => ∑ v : V,
      if (j, v) ∈ s then (if i = j then A i u v else 0) else 0) =
      (fun j : I => if i = j then ∑ v : V,
        if (j, v) ∈ s then A i u v else 0 else 0) := by
    funext j
    by_cases h : i = j <;> simp [h]
  rw [hf]
  simp

/-- Full graph support is componentwise, for every arbitrary global subset. -/
theorem graph_support_disjoint_iff (A : I → V → V → ZMod 2)
    (s : Finset (I × V)) :
    graphSupportWithEmpty (blockAdjacency A) s ↔
      ∀ i, graphSupportWithEmpty (A i) (supportFiber s i) := by
  constructor
  · rintro ⟨hind, hker⟩ i
    constructor
    · intro u hu v hv
      have h := hind (i, u) (mem_supportFiber s i u |>.mp hu)
        (i, v) (mem_supportFiber s i v |>.mp hv)
      simpa [blockAdjacency] using h
    · intro u
      rw [← block_kernel_sum]
      exact hker (i, u)
  · intro h
    constructor
    · rintro ⟨i, u⟩ hu ⟨j, v⟩ hv
      by_cases hij : i = j
      · subst j
        simpa [blockAdjacency] using
          (h i).1 u (mem_supportFiber s i u |>.mpr hu)
            v (mem_supportFiber s i v |>.mpr hv)
      · simp [blockAdjacency, hij]
    · rintro ⟨i, u⟩
      rw [block_kernel_sum]
      exact (h i).2 u

/-- Reconstruct a global vertex subset from its components. -/
def supportUnion (f : I → Finset V) : Finset (I × V) :=
  univ.filter fun u => u.2 ∈ f u.1

omit [DecidableEq I] in
@[simp] theorem mem_supportUnion (f : I → Finset V) (i : I) (v : V) :
    (i, v) ∈ supportUnion f ↔ v ∈ f i := by simp [supportUnion]

@[simp] theorem supportFiber_union (f : I → Finset V) (i : I) :
    supportFiber (supportUnion f) i = f i := by ext v; simp

@[simp] theorem supportUnion_fibers (s : Finset (I × V)) :
    supportUnion (supportFiber s) = s := by
  ext u
  rcases u with ⟨i, v⟩
  simp

/-- The precise support-product bijection, proved from the two graph conditions. -/
def graphSupportEquiv (A : I → V → V → ZMod 2) :
    {s : Finset (I × V) // graphSupportWithEmpty (blockAdjacency A) s} ≃
      ((i : I) → {s : Finset V // graphSupportWithEmpty (A i) s}) where
  toFun s i := ⟨supportFiber s.1 i, (graph_support_disjoint_iff A s.1).mp s.2 i⟩
  invFun f := ⟨supportUnion (fun i => (f i).1), by
    apply (graph_support_disjoint_iff A _).mpr
    intro i
    simpa using (f i).2⟩
  left_inv s := by apply Subtype.ext; simp
  right_inv f := by funext i; apply Subtype.ext; simp

omit [Fintype I] in
theorem support_nonempty_iff (s : Finset (I × V)) :
    s.Nonempty ↔ ∃ i, (supportFiber s i).Nonempty := by
  constructor
  · rintro ⟨⟨i, v⟩, h⟩
    exact ⟨i, v, (mem_supportFiber s i v).mpr h⟩
  · rintro ⟨i, v, h⟩
    exact ⟨(i, v), (mem_supportFiber s i v).mp h⟩

/-- Excluding the empty set excludes exactly the all-empty component tuple. -/
theorem graph_support_nonempty_disjoint_iff (A : I → V → V → ZMod 2)
    (s : Finset (I × V)) :
    (graphSupportWithEmpty (blockAdjacency A) s ∧ s.Nonempty) ↔
      ((∀ i, graphSupportWithEmpty (A i) (supportFiber s i)) ∧
        ∃ i, (supportFiber s i).Nonempty) := by
  rw [graph_support_disjoint_iff, support_nonempty_iff]

end ContextualityTensor

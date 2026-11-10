import ContextualityTensor

open Finset

namespace ContextualityTensor

def selectedContext {C V : Type*} (seed : C → Finset V) : Option C → Finset V
  | none => ∅
  | some c => seed c

/-- The actual vertices of a context: tagged vertices in disjoint blocks. -/
def unionContext {k : ℕ} {C V : Type*} (seed : C → Finset V)
    (q : Fin k → Option C) : Finset (Σ _i : Fin k, V) :=
  univ.sigma fun i => selectedContext seed (q i)

theorem selectedContext_injective {C V : Type*} (seed : C → Finset V)
    (hi : Function.Injective seed) (hne : ∀ c, (seed c).Nonempty) :
    Function.Injective (selectedContext seed) := by
  intro u v h
  cases u with
  | none =>
    cases v with
    | none => rfl
    | some v => exact False.elim ((hne v).ne_empty h.symm)
  | some u =>
    cases v with
    | none => exact False.elim ((hne u).ne_empty h)
    | some v => exact congrArg some (hi h)

/-- Tuple indexing counts distinct actual contexts, provided the seed does. -/
theorem unionContext_injective {k : ℕ} {C V : Type*} (seed : C → Finset V)
    (hi : Function.Injective seed) (hne : ∀ c, (seed c).Nonempty) :
    Function.Injective (unionContext (k := k) seed) := by
  intro q r h
  funext i
  apply selectedContext_injective seed hi hne
  ext v
  have he := congrArg (fun s => Sigma.mk i v ∈ s) h
  simpa [unionContext] using Iff.of_eq he

@[simp] theorem unionContext_empty {k : ℕ} {C V : Type*} (seed : C → Finset V) :
    unionContext (k := k) seed emptyChoice = ∅ := by
  simp [unionContext, emptyChoice, selectedContext]

theorem unionContext_nonempty {k : ℕ} {C V : Type*} (seed : C → Finset V)
    (hi : Function.Injective seed) (hne : ∀ c, (seed c).Nonempty)
    (q : Fin k → Option C) (hq : q ≠ emptyChoice) : (unionContext seed q).Nonempty := by
  by_contra h
  have he : unionContext seed q = ∅ := Finset.not_nonempty_iff_eq_empty.mp h
  apply hq
  apply unionContext_injective seed hi hne
  simpa using he

theorem actual_context_count {k : ℕ} {C V : Type*} [Fintype C] [DecidableEq C]
    [DecidableEq V] (seed : C → Finset V) (hi : Function.Injective seed)
    (hne : ∀ c, (seed c).Nonempty) :
    ((contexts k C).image (unionContext seed)).card + 1 = (Fintype.card C + 1) ^ k := by
  rw [Finset.card_image_of_injective _ (unionContext_injective seed hi hne)]
  exact context_count k C

theorem selected_response {C V : Type*} [DecidableEq V] (seed : C → Finset V)
    (negative : C → Bool) (a : V → Bool) (q : Option C) :
    extend (fun c => response a (negative c) (seed c)) q =
      extend (fun c => sign (negative c)) q * ∏ v ∈ selectedContext seed q, sign (a v) := by
  cases q <;> simp [extend, selectedContext, response]

/-- The product formula uses unrestricted deterministic values of the actual
tagged vertices. It does not assume a factorization of new observable values. -/
theorem union_response {k : ℕ} {C V : Type*} [DecidableEq V]
    (seed : C → Finset V) (negative : C → Bool) (a : Fin k → V → Bool)
    (q : Fin k → Option C) :
    contextValue (fun i c => response (a i) (negative c) (seed c)) q =
      (∏ i, extend (fun c => sign (negative c)) (q i)) *
        ∏ u ∈ unionContext seed q, sign (a u.1 u.2) := by
  simp only [contextValue, selected_response, Finset.prod_mul_distrib,
    unionContext, Finset.prod_sigma]

theorem square_context_injective : Function.Injective squareContext := by decide +kernel
theorem square_context_nonempty : ∀ c, (squareContext c).Nonempty := by decide +kernel
theorem pentagram_context_injective : Function.Injective pentagramContext := by decide +kernel
theorem pentagram_context_nonempty : ∀ c, (pentagramContext c).Nonempty := by decide +kernel

theorem square_actual_context_count (k : ℕ) :
    ((contexts k (Fin 6)).image (unionContext squareContext)).card + 1 = 7 ^ k := by
  simpa using actual_context_count (k := k) squareContext square_context_injective
    square_context_nonempty

theorem pentagram_actual_context_count (k : ℕ) :
    ((contexts k (Fin 5)).image (unionContext pentagramContext)).card + 1 = 6 ^ k := by
  simpa using actual_context_count (k := k) pentagramContext pentagram_context_injective
    pentagram_context_nonempty

end ContextualityTensor

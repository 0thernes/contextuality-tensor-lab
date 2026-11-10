import ContextualityTensor.UnionModel
import ContextualityTensor.Asymptotics

open Finset Filter Topology

namespace ContextualityTensor

def actualContexts {k : ℕ} {C V : Type*} [Fintype C] [DecidableEq C]
    [DecidableEq V] (seed : C → Finset V) : Finset (Finset (Σ _i : Fin k, V)) :=
  (contexts k C).image (unionContext seed)

/-- Sign on an actual vertex subset. On the context family exactly one summand
is nonzero, by the proved injectivity of the union construction. -/
def actualSign {k : ℕ} {C V : Type*} [Fintype C] [DecidableEq C] [DecidableEq V]
    (seed : C → Finset V) (negative : C → Bool) (s : Finset (Σ _i : Fin k, V)) : ℤ :=
  ∑ q ∈ contexts k C, if unionContext seed q = s then
    ∏ i, extend (fun c => sign (negative c)) (q i) else 0

def actualValue {k : ℕ} {C V : Type*} [Fintype C] [DecidableEq C] [DecidableEq V]
    (seed : C → Finset V) (negative : C → Bool) (a : (Σ _i : Fin k, V) → Bool)
    (s : Finset (Σ _i : Fin k, V)) : ℤ :=
  actualSign seed negative s * ∏ v ∈ s, sign (a v)

def actualScore {k : ℕ} {C V : Type*} [Fintype C] [DecidableEq C] [DecidableEq V]
    (seed : C → Finset V) (negative : C → Bool) (a : (Σ _i : Fin k, V) → Bool) : ℤ :=
  ∑ s ∈ actualContexts seed, actualValue seed negative a s

def actualViolations {k : ℕ} {C V : Type*} [Fintype C] [DecidableEq C]
    [DecidableEq V] (seed : C → Finset V) (negative : C → Bool)
    (a : (Σ _i : Fin k, V) → Bool) : ℕ :=
  ((actualContexts seed).filter fun s => actualValue seed negative a s = -1).card

theorem actualSign_union {k : ℕ} {C V : Type*} [Fintype C] [DecidableEq C]
    [DecidableEq V] (seed : C → Finset V) (negative : C → Bool)
    (hi : Function.Injective seed) (hne : ∀ c, (seed c).Nonempty)
    (q : Fin k → Option C) (hq : q ∈ contexts k C) :
    actualSign seed negative (unionContext seed q) =
      ∏ i, extend (fun c => sign (negative c)) (q i) := by
  unfold actualSign
  rw [Finset.sum_eq_single q]
  · simp
  · intro r _ hrq
    have hneq : unionContext seed r ≠ unionContext seed q :=
      fun h => hrq (unionContext_injective seed hi hne h)
    simp [hneq]
  · intro h
    exact (h hq).elim

theorem actualValue_union {k : ℕ} {C V : Type*} [Fintype C] [DecidableEq C]
    [DecidableEq V] (seed : C → Finset V) (negative : C → Bool)
    (hi : Function.Injective seed) (hne : ∀ c, (seed c).Nonempty)
    (a : (Σ _i : Fin k, V) → Bool) (q : Fin k → Option C) (hq : q ∈ contexts k C) :
    actualValue seed negative a (unionContext seed q) =
      contextValue (fun i c => response (fun v => a ⟨i,v⟩) (negative c) (seed c)) q := by
  unfold actualValue
  rw [actualSign_union seed negative hi hne q hq]
  exact (union_response seed negative (fun i v => a ⟨i,v⟩) q).symm

theorem actualScore_eq_score {k : ℕ} {C V : Type*} [Fintype C] [DecidableEq C]
    [DecidableEq V] (seed : C → Finset V) (negative : C → Bool)
    (hi : Function.Injective seed) (hne : ∀ c, (seed c).Nonempty)
    (a : (Σ _i : Fin k, V) → Bool) :
    actualScore seed negative a =
      score (fun i c => response (fun v => a ⟨i,v⟩) (negative c) (seed c)) := by
  unfold actualScore actualContexts score
  rw [Finset.sum_image]
  · exact Finset.sum_congr rfl fun q hq => actualValue_union seed negative hi hne a q hq
  · intro q _ r _ h
    exact unionContext_injective seed hi hne h

theorem actualViolations_eq_violations {k : ℕ} {C V : Type*} [Fintype C]
    [DecidableEq C] [DecidableEq V] (seed : C → Finset V) (negative : C → Bool)
    (hi : Function.Injective seed) (hne : ∀ c, (seed c).Nonempty)
    (a : (Σ _i : Fin k, V) → Bool) :
    actualViolations seed negative a =
      violations (fun i c => response (fun v => a ⟨i,v⟩) (negative c) (seed c)) := by
  unfold actualViolations actualContexts
  rw [Finset.filter_image, Finset.card_image_of_injective _
    (unionContext_injective seed hi hne)]
  unfold violations
  congr 1
  apply Finset.filter_congr
  intro q hq
  rw [actualValue_union seed negative hi hne a q hq]

/-- Exact minimum directly on the family of actual vertex subsets and arbitrary
single values assigned to its vertices. This is the end-to-end combinatorial theorem. -/
theorem global_actual_square_minimum (k : ℕ) :
    (∃ a : (Σ _i : Fin k, Fin 9) → Bool,
      actualViolations squareContext (fun c => c == 5) a = (7 ^ k - 5 ^ k) / 2) ∧
    (∀ a : (Σ _i : Fin k, Fin 9) → Bool,
      (7 ^ k - 5 ^ k) / 2 ≤ actualViolations squareContext (fun c => c == 5) a) := by
  constructor
  · refine ⟨fun _ => false, ?_⟩
    rw [actualViolations_eq_violations squareContext _ square_context_injective
      square_context_nonempty]
    exact square_degree_nat k
  · intro a
    rw [actualViolations_eq_violations squareContext _ square_context_injective
      square_context_nonempty]
    exact (square_minimum_closed_form k).2 (fun i v => a ⟨i,v⟩)

theorem global_actual_pentagram_minimum (k : ℕ) :
    (∃ a : (Σ _i : Fin k, Fin 10) → Bool,
      actualViolations pentagramContext (fun c => c == 4) a = (6 ^ k - 4 ^ k) / 2) ∧
    (∀ a : (Σ _i : Fin k, Fin 10) → Bool,
      (6 ^ k - 4 ^ k) / 2 ≤ actualViolations pentagramContext (fun c => c == 4) a) := by
  constructor
  · refine ⟨fun _ => false, ?_⟩
    rw [actualViolations_eq_violations pentagramContext _ pentagram_context_injective
      pentagram_context_nonempty]
    exact pentagram_degree_nat k
  · intro a
    rw [actualViolations_eq_violations pentagramContext _ pentagram_context_injective
      pentagram_context_nonempty]
    exact (pentagram_minimum_closed_form k).2 (fun i v => a ⟨i,v⟩)

noncomputable def actualSquareEpsilon (k : ℕ) : ℝ :=
  2 * (actualViolations (k := k) squareContext (fun c => c == 5) (fun _ => false) : ℝ) /
    (actualContexts (k := k) squareContext).card

noncomputable def actualPentagramEpsilon (k : ℕ) : ℝ :=
  2 * (actualViolations (k := k) pentagramContext (fun c => c == 4) (fun _ => false) : ℝ) /
    (actualContexts (k := k) pentagramContext).card

theorem actualSquareEpsilon_eq (k : ℕ) : actualSquareEpsilon k = squareEpsilon k := by
  unfold actualSquareEpsilon actualContexts
  rw [actualViolations_eq_violations squareContext _ square_context_injective
    square_context_nonempty, Finset.card_image_of_injective _
      (unionContext_injective squareContext square_context_injective square_context_nonempty)]
  exact (square_epsilon_is_count_ratio k).symm

theorem actualPentagramEpsilon_eq (k : ℕ) : actualPentagramEpsilon k = pentagramEpsilon k := by
  unfold actualPentagramEpsilon actualContexts
  rw [actualViolations_eq_violations pentagramContext _ pentagram_context_injective
    pentagram_context_nonempty, Finset.card_image_of_injective _
      (unionContext_injective pentagramContext pentagram_context_injective pentagram_context_nonempty)]
  exact (pentagram_epsilon_is_count_ratio k).symm

theorem actual_square_epsilon_tends_to_one : Tendsto actualSquareEpsilon atTop (𝓝 1) := by
  have h : actualSquareEpsilon = squareEpsilon := funext actualSquareEpsilon_eq
  rw [h]
  exact square_epsilon_tends_to_one

theorem actual_pentagram_epsilon_tends_to_one : Tendsto actualPentagramEpsilon atTop (𝓝 1) := by
  have h : actualPentagramEpsilon = pentagramEpsilon := funext actualPentagramEpsilon_eq
  rw [h]
  exact pentagram_epsilon_tends_to_one

end ContextualityTensor

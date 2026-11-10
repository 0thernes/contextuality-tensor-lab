import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Ring.Finset
import Mathlib.Data.Fintype.Option
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic

/-!
# Exact contextuality amplification by disjoint unions

The vertices in different blocks are disjoint. A global deterministic assignment
is an arbitrary tuple of local assignments, with no extra multiplicativity
assumption. A context chooses either no context or one context in every block;
the all-empty choice is excluded. Its response is the product of the local
responses. The statements below count violations of these actual signed
constraints, not a relaxation of the assignment space.
-/

open Finset

namespace ContextualityTensor

def sign (b : Bool) : ℤ := if b then -1 else 1

@[simp] theorem abs_sign (b : Bool) : |sign b| = 1 := by cases b <;> decide

def response {V : Type*} [DecidableEq V] (a : V → Bool) (negative : Bool)
    (context : Finset V) : ℤ := sign negative * ∏ v ∈ context, sign (a v)

theorem abs_response {V : Type*} [DecidableEq V] (a : V → Bool)
    (negative : Bool) (context : Finset V) : |response a negative context| = 1 := by
  simp [response, abs_mul, abs_prod]

def extend {C : Type*} (f : C → ℤ) : Option C → ℤ
  | none => 1
  | some c => f c

def contextValue {k : ℕ} {C : Type*} (f : Fin k → C → ℤ)
    (q : Fin k → Option C) : ℤ := ∏ i, extend (f i) (q i)

def emptyChoice {k : ℕ} {C : Type*} : Fin k → Option C := fun _ => none

def contexts (k : ℕ) (C : Type*) [Fintype C] [DecidableEq C] :
    Finset (Fin k → Option C) := univ.erase emptyChoice

def score {k : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (f : Fin k → C → ℤ) : ℤ := ∑ q ∈ contexts k C, contextValue f q

def violations {k : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (f : Fin k → C → ℤ) : ℕ :=
  ((contexts k C).filter fun q => contextValue f q = -1).card

@[simp] theorem contextValue_empty {k : ℕ} {C : Type*} (f : Fin k → C → ℤ) :
    contextValue f emptyChoice = 1 := by simp [contextValue, emptyChoice, extend]

theorem context_count (k : ℕ) (C : Type*) [Fintype C] [DecidableEq C] :
    (contexts k C).card + 1 = (Fintype.card C + 1) ^ k := by
  have h := Finset.card_erase_add_one (s := (univ : Finset (Fin k → Option C)))
    (mem_univ emptyChoice)
  simpa [contexts, Fintype.card_fun] using h

theorem score_factorization {k : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (f : Fin k → C → ℤ) : score f + 1 = ∏ i, (1 + ∑ c, f i c) := by
  have he := Finset.sum_erase_add (s := (univ : Finset (Fin k → Option C)))
    (f := contextValue f) (mem_univ emptyChoice)
  have hp := Fintype.prod_sum (fun i q => extend (f i) q)
  simpa [score, contexts, contextValue, emptyChoice, extend, Fintype.sum_option,
    add_comm] using he.trans hp.symm

theorem abs_contextValue {k : ℕ} {C : Type*} (f : Fin k → C → ℤ)
    (hf : ∀ i c, |f i c| = 1) (q : Fin k → Option C) :
    |contextValue f q| = 1 := by
  rw [contextValue, abs_prod]
  apply Finset.prod_eq_one
  intro i _
  cases q i with
  | none => simp [extend]
  | some c => exact hf i c

theorem score_violations {k : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (f : Fin k → C → ℤ) (hf : ∀ i c, |f i c| = 1) :
    score f = (contexts k C).card - 2 * (violations f : ℤ) := by
  have hv (q : Fin k → Option C) :
      contextValue f q = 1 - 2 * (if contextValue f q = -1 then (1 : ℤ) else 0) := by
    have h := abs_contextValue f hf q
    rcases (abs_eq (by norm_num : (0 : ℤ) ≤ 1)).mp h with h | h <;> simp [h]
  unfold score
  rw [Finset.sum_congr rfl (fun q _ => hv q)]
  rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
  simp only [Finset.sum_const, nsmul_eq_mul, mul_one, Finset.sum_boole, violations]

theorem score_upper_bound {k : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (f : Fin k → C → ℤ) (bound : ℤ) (_hbound : 0 ≤ bound)
    (hf : ∀ i, |1 + ∑ c, f i c| ≤ bound) : score f ≤ bound ^ k - 1 := by
  have hp : |∏ i, (1 + ∑ c, f i c)| ≤ bound ^ k := by
    rw [abs_prod]
    calc
      _ ≤ ∏ _i : Fin k, bound := Finset.prod_le_prod₀ (fun i _ => abs_nonneg _)
        (fun i _ => hf i)
      _ = bound ^ k := by simp
  rw [← score_factorization] at hp
  have := le_abs_self (score f + 1)
  linarith

def squareContext : Fin 6 → Finset (Fin 9) :=
  ![{0,1,2}, {3,4,5}, {6,7,8}, {0,3,6}, {1,4,7}, {2,5,8}]

def squareResponse (a : Fin 9 → Bool) (c : Fin 6) : ℤ :=
  response a (c == 5) (squareContext c)

def pentagramContext : Fin 5 → Finset (Fin 10) :=
  ![{0,1,2,6}, {0,4,5,7}, {3,1,5,8}, {3,4,2,9}, {6,7,8,9}]

def pentagramResponse (a : Fin 10 → Bool) (c : Fin 5) : ℤ :=
  response a (c == 4) (pentagramContext c)

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem square_local_bound : ∀ a : Fin 9 → Bool,
    |1 + ∑ c, squareResponse a c| ≤ 5 := by decide +kernel

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem pentagram_local_bound : ∀ a : Fin 10 → Bool,
    |1 + ∑ c, pentagramResponse a c| ≤ 4 := by decide +kernel

theorem square_local_witness : (∑ c, squareResponse (fun _ => false) c) = 4 := by decide
theorem pentagram_local_witness : (∑ c, pentagramResponse (fun _ => false) c) = 3 := by decide

theorem square_bound (k : ℕ) (a : Fin k → Fin 9 → Bool) :
    score (fun i => squareResponse (a i)) ≤ 5 ^ k - 1 :=
  score_upper_bound _ 5 (by norm_num) fun i => square_local_bound (a i)

theorem pentagram_bound (k : ℕ) (a : Fin k → Fin 10 → Bool) :
    score (fun i => pentagramResponse (a i)) ≤ 4 ^ k - 1 :=
  score_upper_bound _ 4 (by norm_num) fun i => pentagram_local_bound (a i)

theorem square_witness (k : ℕ) :
    score (k := k) (fun _ => squareResponse (fun _ => false)) = 5 ^ k - 1 := by
  have h := score_factorization (k := k) (fun _ => squareResponse (fun _ => false))
  simp only [square_local_witness] at h
  norm_num at h
  linarith

theorem pentagram_witness (k : ℕ) :
    score (k := k) (fun _ => pentagramResponse (fun _ => false)) = 4 ^ k - 1 := by
  have h := score_factorization (k := k) (fun _ => pentagramResponse (fun _ => false))
  simp only [pentagram_local_witness] at h
  norm_num at h
  linarith

theorem square_context_count (k : ℕ) : (contexts k (Fin 6)).card + 1 = 7 ^ k := by
  simpa using context_count k (Fin 6)

theorem pentagram_context_count (k : ℕ) : (contexts k (Fin 5)).card + 1 = 6 ^ k := by
  simpa using context_count k (Fin 5)

theorem square_violation_lower_bound (k : ℕ) (a : Fin k → Fin 9 → Bool) :
    (7 : ℤ) ^ k - 5 ^ k ≤ 2 * (violations (fun i => squareResponse (a i)) : ℤ) := by
  have hs := score_violations (fun i => squareResponse (a i))
    (fun i c => abs_response (a i) (c == 5) (squareContext c))
  have hb := square_bound k a
  have hc : ((contexts k (Fin 6)).card : ℤ) + 1 = 7 ^ k := by
    exact_mod_cast square_context_count k
  linarith

theorem pentagram_violation_lower_bound (k : ℕ) (a : Fin k → Fin 10 → Bool) :
    (6 : ℤ) ^ k - 4 ^ k ≤ 2 * (violations (fun i => pentagramResponse (a i)) : ℤ) := by
  have hs := score_violations (fun i => pentagramResponse (a i))
    (fun i c => abs_response (a i) (c == 4) (pentagramContext c))
  have hb := pentagram_bound k a
  have hc : ((contexts k (Fin 5)).card : ℤ) + 1 = 6 ^ k := by
    exact_mod_cast pentagram_context_count k
  linarith

theorem square_exact_degree (k : ℕ) :
    2 * (violations (k := k) (fun _ => squareResponse (fun _ => false)) : ℤ) =
      (7 : ℤ) ^ k - 5 ^ k := by
  have hs := score_violations (k := k) (fun _ => squareResponse (fun _ => false))
    (fun _ c => abs_response (fun _ => false) (c == 5) (squareContext c))
  have hw := square_witness k
  have hc : ((contexts k (Fin 6)).card : ℤ) + 1 = 7 ^ k := by
    exact_mod_cast square_context_count k
  linarith

theorem pentagram_exact_degree (k : ℕ) :
    2 * (violations (k := k) (fun _ => pentagramResponse (fun _ => false)) : ℤ) =
      (6 : ℤ) ^ k - 4 ^ k := by
  have hs := score_violations (k := k) (fun _ => pentagramResponse (fun _ => false))
    (fun _ c => abs_response (fun _ => false) (c == 4) (pentagramContext c))
  have hw := pentagram_witness k
  have hc : ((contexts k (Fin 5)).card : ℤ) + 1 = 6 ^ k := by
    exact_mod_cast pentagram_context_count k
  linarith

theorem square_minimum (k : ℕ) (a : Fin k → Fin 9 → Bool) :
    violations (k := k) (fun _ => squareResponse (fun _ => false)) ≤
      violations (fun i => squareResponse (a i)) := by
  have h1 := square_exact_degree k
  have h2 := square_violation_lower_bound k a
  omega

theorem pentagram_minimum (k : ℕ) (a : Fin k → Fin 10 → Bool) :
    violations (k := k) (fun _ => pentagramResponse (fun _ => false)) ≤
      violations (fun i => pentagramResponse (a i)) := by
  have h1 := pentagram_exact_degree k
  have h2 := pentagram_violation_lower_bound k a
  omega

theorem square_degree_nat (k : ℕ) :
    violations (k := k) (fun _ => squareResponse (fun _ => false)) =
      (7 ^ k - 5 ^ k) / 2 := by
  have h := square_exact_degree k
  have hi : (2 : ℤ) * violations (k := k) (fun _ => squareResponse (fun _ => false)) +
      5 ^ k = 7 ^ k := by linarith
  have hn : 2 * violations (k := k) (fun _ => squareResponse (fun _ => false)) +
      5 ^ k = 7 ^ k := by exact_mod_cast hi
  omega

theorem pentagram_degree_nat (k : ℕ) :
    violations (k := k) (fun _ => pentagramResponse (fun _ => false)) =
      (6 ^ k - 4 ^ k) / 2 := by
  have h := pentagram_exact_degree k
  have hi : (2 : ℤ) * violations (k := k) (fun _ => pentagramResponse (fun _ => false)) +
      4 ^ k = 6 ^ k := by linarith
  have hn : 2 * violations (k := k) (fun _ => pentagramResponse (fun _ => false)) +
      4 ^ k = 6 ^ k := by exact_mod_cast hi
  omega

/-- Exact minimum, with both an attaining assignment and the universal lower bound. -/
theorem square_minimum_closed_form (k : ℕ) :
    (∃ a : Fin k → Fin 9 → Bool,
      violations (fun i => squareResponse (a i)) = (7 ^ k - 5 ^ k) / 2) ∧
    (∀ a : Fin k → Fin 9 → Bool,
      (7 ^ k - 5 ^ k) / 2 ≤ violations (fun i => squareResponse (a i))) := by
  constructor
  · exact ⟨fun _ _ => false, square_degree_nat k⟩
  · intro a
    rw [← square_degree_nat]
    exact square_minimum k a

theorem pentagram_minimum_closed_form (k : ℕ) :
    (∃ a : Fin k → Fin 10 → Bool,
      violations (fun i => pentagramResponse (a i)) = (6 ^ k - 4 ^ k) / 2) ∧
    (∀ a : Fin k → Fin 10 → Bool,
      (6 ^ k - 4 ^ k) / 2 ≤ violations (fun i => pentagramResponse (a i))) := by
  constructor
  · exact ⟨fun _ _ => false, pentagram_degree_nat k⟩
  · intro a
    rw [← pentagram_degree_nat]
    exact pentagram_minimum k a

end ContextualityTensor

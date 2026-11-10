import ContextualityTensor
import Mathlib.Analysis.SpecificLimits.Basic

open Filter Topology

namespace ContextualityTensor

/-- The tolerated error parameter used in the source paper, for the square family. -/
noncomputable def squareEpsilon (k : ℕ) : ℝ := ((7 : ℝ) ^ k - 5 ^ k) / (7 ^ k - 1)

/-- The same parameter for the pentagram family. -/
noncomputable def pentagramEpsilon (k : ℕ) : ℝ := ((6 : ℝ) ^ k - 4 ^ k) / (6 ^ k - 1)

theorem ratio_normalization (a b : ℝ) (ha : a ≠ 0) (k : ℕ) :
    (a ^ k - b ^ k) / (a ^ k - 1) =
      (1 - (b / a) ^ k) / (1 - (1 / a) ^ k) := by
  have hk : a ^ k ≠ 0 := pow_ne_zero _ ha
  rw [div_pow, div_pow, one_pow]
  field_simp

theorem amplification_limit (a b : ℝ) (ha : 1 < a) (hb : 0 ≤ b) (hba : b < a) :
    Tendsto (fun k : ℕ => (a ^ k - b ^ k) / (a ^ k - 1)) atTop (𝓝 1) := by
  have ha0 : 0 < a := lt_trans zero_lt_one ha
  have h1 := tendsto_pow_atTop_nhds_zero_of_lt_one
    (div_nonneg hb ha0.le) ((div_lt_one ha0).mpr hba)
  have h2 := tendsto_pow_atTop_nhds_zero_of_lt_one
    (div_nonneg (by norm_num : (0 : ℝ) ≤ 1) ha0.le) ((div_lt_one ha0).mpr ha)
  have hc : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1) := tendsto_const_nhds
  have h := (hc.sub h1).div (hc.sub h2)
    (by norm_num : (1 : ℝ) - 0 ≠ 0)
  have hn : (fun k : ℕ => (a ^ k - b ^ k) / (a ^ k - 1)) =
      (fun k : ℕ => (1 - (b / a) ^ k) / (1 - (1 / a) ^ k)) :=
    funext (ratio_normalization a b ha0.ne')
  rw [hn]
  convert h using 1
  simp

theorem square_epsilon_tends_to_one : Tendsto squareEpsilon atTop (𝓝 1) := by
  exact amplification_limit 7 5 (by norm_num) (by norm_num) (by norm_num)

theorem pentagram_epsilon_tends_to_one : Tendsto pentagramEpsilon atTop (𝓝 1) := by
  exact amplification_limit 6 4 (by norm_num) (by norm_num) (by norm_num)

theorem square_epsilon_is_count_ratio (k : ℕ) :
    squareEpsilon k =
      2 * (violations (k := k) (fun _ => squareResponse (fun _ => false)) : ℝ) /
        (contexts k (Fin 6)).card := by
  have hs : 2 * (violations (k := k) (fun _ => squareResponse (fun _ => false)) : ℝ) =
      (7 : ℝ) ^ k - 5 ^ k := by exact_mod_cast square_exact_degree k
  have hc : ((contexts k (Fin 6)).card : ℝ) + 1 = 7 ^ k := by
    exact_mod_cast square_context_count k
  have hc' : ((contexts k (Fin 6)).card : ℝ) = 7 ^ k - 1 := by linarith
  rw [hs, hc']
  rfl

theorem pentagram_epsilon_is_count_ratio (k : ℕ) :
    pentagramEpsilon k =
      2 * (violations (k := k) (fun _ => pentagramResponse (fun _ => false)) : ℝ) /
        (contexts k (Fin 5)).card := by
  have hs : 2 * (violations (k := k) (fun _ => pentagramResponse (fun _ => false)) : ℝ) =
      (6 : ℝ) ^ k - 4 ^ k := by exact_mod_cast pentagram_exact_degree k
  have hc : ((contexts k (Fin 5)).card : ℝ) + 1 = 6 ^ k := by
    exact_mod_cast pentagram_context_count k
  have hc' : ((contexts k (Fin 5)).card : ℝ) = 6 ^ k - 1 := by linarith
  rw [hs, hc']
  rfl

end ContextualityTensor

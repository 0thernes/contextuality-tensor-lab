import ContextualityTensor
import Mathlib.LinearAlgebra.Matrix.Kronecker
import Mathlib.Basic.Complex.Basic

/-! Explicit integral matrices for the two-qubit square and its four-qubit
disjoint union. All nine square observables have real integral entries,
including Y tensor Y. Integral identities embed faithfully into complex
matrices. This file checks the physical signs used by squareResponse. -/

open Matrix
open scoped Kronecker

namespace ContextualityTensor

abbrev Mat4 := Matrix (Fin 4) (Fin 4) ℤ
abbrev Mat16 := Matrix (Fin 4 × Fin 4) (Fin 4 × Fin 4) ℤ

/-- XI, IX, XX, IZ, ZI, ZZ, XZ, ZX, YY in computational basis order. -/
def squareMatrix : Fin 9 → Mat4 := ![
  !![0,0,1,0; 0,0,0,1; 1,0,0,0; 0,1,0,0],
  !![0,1,0,0; 1,0,0,0; 0,0,0,1; 0,0,1,0],
  !![0,0,0,1; 0,0,1,0; 0,1,0,0; 1,0,0,0],
  !![1,0,0,0; 0,-1,0,0; 0,0,1,0; 0,0,0,-1],
  !![1,0,0,0; 0,1,0,0; 0,0,-1,0; 0,0,0,-1],
  !![1,0,0,0; 0,-1,0,0; 0,0,-1,0; 0,0,0,1],
  !![0,0,1,0; 0,0,0,-1; 1,0,0,0; 0,-1,0,0],
  !![0,1,0,0; 1,0,0,0; 0,0,0,-1; 0,0,-1,0],
  !![0,0,0,-1; 0,0,1,0; 0,1,0,0; -1,0,0,0]]

def squareContextList : Fin 6 → List (Fin 9) :=
  ![[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8]]

theorem square_context_list_matches (c : Fin 6) :
    (squareContextList c).toFinset = squareContext c := by revert c; decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem square_observables : ∀ i : Fin 9,
    squareMatrix i * squareMatrix i = 1 ∧ (squareMatrix i).transpose = squareMatrix i := by decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem square_context_commute : ∀ (c : Fin 6) (i j : Fin 9),
    i ∈ squareContext c → j ∈ squareContext c →
    squareMatrix i * squareMatrix j = squareMatrix j * squareMatrix i := by decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem square_context_products : ∀ c : Fin 6,
    ((squareContextList c).map squareMatrix).prod =
      if c == 5 then -(1 : Mat4) else 1 := by decide

def leftEmbed : Mat4 →* Mat16 where
  toFun A := A ⊗ₖ (1 : Mat4)
  map_one' := Matrix.one_kronecker_one
  map_mul' A B := by rw [← Matrix.mul_kronecker_mul]; simp

def rightEmbed : Mat4 →* Mat16 where
  toFun A := (1 : Mat4) ⊗ₖ A
  map_one' := Matrix.one_kronecker_one
  map_mul' A B := by rw [← Matrix.mul_kronecker_mul]; simp

theorem disjoint_blocks_commute (A B : Mat4) :
    leftEmbed A * rightEmbed B = rightEmbed B * leftEmbed A := by
  change (A ⊗ₖ (1 : Mat4)) * ((1 : Mat4) ⊗ₖ B) =
    ((1 : Mat4) ⊗ₖ B) * (A ⊗ₖ (1 : Mat4))
  rw [← Matrix.mul_kronecker_mul, ← Matrix.mul_kronecker_mul]
  simp

def optionalContext : Option (Fin 6) → List (Fin 9)
  | none => []
  | some c => squareContextList c

def optionalSign : Option (Fin 6) → ℤ
  | none => 1
  | some c => sign (c == 5)

def fourQubitContext (c d : Option (Fin 6)) : List Mat16 :=
  ((optionalContext c).map fun i => leftEmbed (squareMatrix i)) ++
  ((optionalContext d).map fun i => rightEmbed (squareMatrix i))

theorem optional_context_product (c : Option (Fin 6)) :
    ((optionalContext c).map squareMatrix).prod = optionalSign c • (1 : Mat4) := by
  cases c with
  | none => simp [optionalContext, optionalSign]
  | some c =>
    rw [optionalContext, square_context_products]
    by_cases h : c == 5 <;> simp [optionalSign, sign, h]

/-- Every one of the 48 nonempty four-qubit contexts has the declared sign.
The statement also includes the empty choice, whose matrix product is I. -/
theorem four_qubit_context_product (c d : Option (Fin 6)) :
    (fourQubitContext c d).prod = (optionalSign c * optionalSign d) • (1 : Mat16) := by
  simp only [fourQubitContext, List.prod_append]
  have hl : ((optionalContext c).map fun i => leftEmbed (squareMatrix i)).prod =
      leftEmbed (((optionalContext c).map squareMatrix).prod) := by
    rw [map_list_prod]; simp only [List.map_map, Function.comp_def]
  have hr : ((optionalContext d).map fun i => rightEmbed (squareMatrix i)).prod =
      rightEmbed (((optionalContext d).map squareMatrix).prod) := by
    rw [map_list_prod]; simp only [List.map_map, Function.comp_def]
  rw [hl, hr, optional_context_product, optional_context_product]
  change ((optionalSign c • (1 : Mat4)) ⊗ₖ (1 : Mat4)) *
      ((1 : Mat4) ⊗ₖ (optionalSign d • (1 : Mat4))) = _
  rw [Matrix.smul_kronecker, Matrix.kronecker_smul, Matrix.one_kronecker_one]
  simp

def fourQubitObservable (v : Fin 2 × Fin 9) : Mat16 :=
  if v.1 = 0 then leftEmbed (squareMatrix v.2) else rightEmbed (squareMatrix v.2)

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem four_qubit_observables_distinct : Function.Injective fourQubitObservable := by decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem four_qubit_observables_nonidentity : ∀ v, fourQubitObservable v ≠ 1 := by decide

/-- The integral context identity gives the physical complex matrix identity. -/
theorem four_qubit_complex_context (c d : Option (Fin 6)) :
    ((fourQubitContext c d).prod).map (Int.castRingHom ℂ) =
      ((optionalSign c * optionalSign d : ℤ) : ℂ) •
        (1 : Matrix (Fin 4 × Fin 4) (Fin 4 × Fin 4) ℂ) := by
  rw [four_qubit_context_product]
  ext i j
  simp only [Matrix.map_apply, Matrix.smul_apply, Matrix.one_apply, smul_eq_mul]
  by_cases h : i = j <;> simp [h]

end ContextualityTensor

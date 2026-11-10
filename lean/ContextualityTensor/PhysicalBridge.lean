import ContextualityTensor.ActualModel
import ContextualityTensor.Pauli

open Finset

namespace ContextualityTensor

def fourQubitVertexList (c d : Option (Fin 6)) : List (Σ _i : Fin 2, Fin 9) :=
  ((optionalContext c).map fun v => Sigma.mk 0 v) ++
  ((optionalContext d).map fun v => Sigma.mk 1 v)

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem four_qubit_vertex_list_matches : ∀ c d : Option (Fin 6),
    (fourQubitVertexList c d).toFinset = unionContext squareContext ![c,d] := by
  decide +kernel

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem four_qubit_vertex_list_nodup : ∀ c d : Option (Fin 6),
    (fourQubitVertexList c d).Nodup := by decide +kernel

theorem four_qubit_matrix_list_matches (c d : Option (Fin 6)) :
    (fourQubitVertexList c d).map (fun v => fourQubitObservable (v.1,v.2)) =
      fourQubitContext c d := by
  simp [fourQubitVertexList, fourQubitContext, List.map_append, List.map_map,
    Function.comp_def, fourQubitObservable]

theorem optional_sign_matches (q : Option (Fin 6)) :
    extend (fun c => sign (c == 5)) q = optionalSign q := by cases q <;> rfl

theorem actual_four_qubit_sign (q : Fin 2 → Option (Fin 6)) (hq : q ∈ contexts 2 (Fin 6)) :
    actualSign squareContext (fun c => c == 5) (unionContext squareContext q) =
      optionalSign (q 0) * optionalSign (q 1) := by
  rw [actualSign_union squareContext _ square_context_injective square_context_nonempty q hq]
  simp only [Fin.prod_univ_two, optional_sign_matches]

/-- The quantum scalar sign is exactly the sign used by the actual-context
optimization, for all 48 nonempty four-qubit contexts. -/
theorem actual_four_qubit_operator_sign (q : Fin 2 → Option (Fin 6))
    (hq : q ∈ contexts 2 (Fin 6)) :
    (fourQubitContext (q 0) (q 1)).prod =
      actualSign squareContext (fun c => c == 5) (unionContext squareContext q) • (1 : Mat16) := by
  rw [actual_four_qubit_sign q hq]
  exact four_qubit_context_product (q 0) (q 1)

end ContextualityTensor

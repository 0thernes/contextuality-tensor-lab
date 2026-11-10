import ContextualityTensor.ActualModel
import ContextualityTensor.Pauli
import ContextualityTensor.Support
import ContextualityTensor.PhysicalBridge

#check ContextualityTensor.square_minimum_closed_form
#check ContextualityTensor.pentagram_minimum_closed_form
#check ContextualityTensor.square_epsilon_tends_to_one
#check ContextualityTensor.pentagram_epsilon_tends_to_one
#print axioms ContextualityTensor.score_factorization
#print axioms ContextualityTensor.score_violations
#print axioms ContextualityTensor.square_minimum_closed_form
#print axioms ContextualityTensor.pentagram_minimum_closed_form
#print axioms ContextualityTensor.unionContext_injective
#print axioms ContextualityTensor.union_response
#print axioms ContextualityTensor.square_actual_context_count
#print axioms ContextualityTensor.pentagram_actual_context_count
#print axioms ContextualityTensor.square_epsilon_is_count_ratio
#print axioms ContextualityTensor.pentagram_epsilon_is_count_ratio
#print axioms ContextualityTensor.square_epsilon_tends_to_one
#print axioms ContextualityTensor.pentagram_epsilon_tends_to_one

#check ContextualityTensor.global_actual_square_minimum
#check ContextualityTensor.global_actual_pentagram_minimum
#check ContextualityTensor.actual_square_epsilon_tends_to_one
#check ContextualityTensor.actual_pentagram_epsilon_tends_to_one

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let all := env.constants.toList.filter fun (name, info) =>
    (`ContextualityTensor).isPrefixOf name && info.isTheorem
  let sorted := all.toArray.qsort fun a b => a.1.toString < b.1.toString
  let allowed : Array Name := #[`propext, `Classical.choice, `Quot.sound]
  if sorted.isEmpty then
    throwError "No project theorems found for axiom audit"
  for (name, _) in sorted do
    let axioms ← Lean.collectAxioms name
    let forbidden := axioms.filter fun a => !allowed.contains a
    if !forbidden.isEmpty then
      throwError "Disallowed axioms for {name}: {forbidden}"
    let record := Json.mkObj [
      ("theorem", toJson name.toString),
      ("axioms", toJson (axioms.map Name.toString))]
    logInfo m!"AXIOM_AUDIT {record.compress}"
  logInfo m!"AXIOM_AUDIT_COUNT {sorted.size}"

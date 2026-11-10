"""Rebuild exact certificate and adversarial checks. Run from any directory."""
import copy
import hashlib
import json
import sys
from collections import Counter
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
from certificates import (SQUARE, PENTAGRAM, validate, compose, masks, all_scores,
                          hypergraph_support, spectrum, exact_family, noisy_quantum_score)

def run():
    checks, configs = [], []
    for seed, expected in [(SQUARE, {-4, 0, 4}), (PENTAGRAM, {-5, -1, 3})]:
        assert validate(seed)
        assert set(hypergraph_support(seed)) == set(masks(seed))
        scores = all_scores(seed)
        assert set(scores) == expected
        assert max(scores) == len(seed["contexts"])-2
        checks.append({"name": seed["name"], "assignments": len(scores),
                       "score_multiplicities": dict(sorted(Counter(scores).items())),
                       "full_hypergraph_support_verified": True})
    two = compose([SQUARE, SQUARE])
    assert validate(two)
    assert set(hypergraph_support(two)) == set(masks(two))
    scores = all_scores(two)
    base = all_scores(SQUARE)
    # Every unrestricted 18-variable assignment, not just selected witnesses.
    for a, score in enumerate(scores):
        assert score+1 == (base[a & 511]+1)*(base[a >> 9]+1)
    assert Counter(scores) == spectrum([SQUARE, SQUARE])
    assert max(scores) == 24 and (len(two["contexts"])-max(scores))//2 == 12
    checks.append({"name": "two_squares", "assignments": len(scores), "vertex_subsets": 2**18,
                   "score_multiplicities": dict(sorted(Counter(scores).items())),
                   "full_hypergraph_support_verified": True, "best_assignment": scores.index(max(scores)),
                   "classical_bound": max(scores), "degree": 12,
                   "context_size_histogram": dict(sorted(Counter(map(len, two["contexts"])).items()))})
    configs.append(two)
    # Arbitrary mixtures check the negative-endpoint issue in the product formula.
    for seeds in [[PENTAGRAM, PENTAGRAM], [SQUARE, PENTAGRAM], [SQUARE]*3, [PENTAGRAM]*3]:
        cfg = compose(seeds)
        assert validate(cfg)
        dist = spectrum(seeds)
        b = max(dist)
        if len(set(s["name"] for s in seeds)) == 1:
            expected = exact_family(seeds[0]["name"], len(seeds))
            assert b == expected["classical_bound"]
            assert len(cfg["contexts"]) == expected["contexts"]
        checks.append({"name": cfg["name"], "spectrum_assignments_counted": sum(dist.values()),
                       "method": "exact convolution of independently enumerated local score multiplicities",
                       "contexts": len(cfg["contexts"]), "classical_bound": b,
                       "degree": (len(cfg["contexts"])-b)//2})
    negative = []
    for name, mutate in [
        ("flipped_quantum_sign", lambda c: c["signs"].__setitem__(0, -c["signs"][0])),
        ("incompatible_context", lambda c: c["contexts"].__setitem__(0, [0, 4, 2])),
        ("duplicate_observable", lambda c: c["observables"].__setitem__(0, c["observables"][1])),
        ("duplicate_context", lambda c: (c["contexts"].append(c["contexts"][0]), c["signs"].append(c["signs"][0]))),
    ]:
        bad = copy.deepcopy(SQUARE)
        mutate(bad)
        try:
            validate(bad)
        except AssertionError:
            negative.append(name)
        else:
            raise AssertionError("negative control incorrectly accepted: "+name)
    missing = copy.deepcopy(two)
    missing["contexts"].pop()
    missing["signs"].pop()
    assert validate(missing)  # Valid subset, but it is not the FULL support.
    assert set(hypergraph_support(missing)) != set(masks(missing))
    negative.append("missing_full_support_context")
    for kind in ["square", "pentagram"]:
        for k in range(1, 8):
            b = exact_family(kind, k)["classical_bound"]
            assert noisy_quantum_score(kind, k, "1/20") > b
            assert noisy_quantum_score(kind, k, "1/10") < b
    report = {"status": "passed", "arithmetic": "exact integers and rational numbers",
              "checks": checks, "negative_controls_rejected": negative,
              "family_values": [exact_family(s, k) for s in ["square", "pentagram"] for k in range(1, 13)],
              "noise_checks": {"p_1_over_20": "violation for k=1..7 both families",
                               "p_1_over_10": "no violation of this inequality for k=1..7 both families"},
              "claim_scope": "finite exact verification plus closed-form family values; Lean proof recorded separately"}
    out = ROOT / "results"
    out.mkdir(exist_ok=True)
    for filename, value in [("exact-certificate.json", report), ("four-qubit-square.json", two)]:
        (out / filename).write_text(json.dumps(value, indent=2)+"\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "full_four_qubit_assignments": len(scores),
                      "four_qubit_bound": 24, "four_qubit_degree": 12,
                      "negative_controls": len(negative)}, indent=2))
    return report

if __name__ == "__main__":
    run()

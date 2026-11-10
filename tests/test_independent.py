"""Independent literal Gaussian-integer matrix and set-based checks.

Does not use certificates.multiply/commute to derive quantum contexts or signs.
The tuple representation (real integer, imaginary integer) uses no floats.
"""
import copy
import itertools
import subprocess
import sys
import unittest
from collections import Counter
from fractions import Fraction
from functools import lru_cache
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
import certificates as production

ZERO, ONE, MINUS, IMAG, NIMAG = (0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)
LITERAL = {
    "I": ((ONE, ZERO), (ZERO, ONE)),
    "X": ((ZERO, ONE), (ONE, ZERO)),
    "Y": ((ZERO, NIMAG), (IMAG, ZERO)),
    "Z": ((ONE, ZERO), (ZERO, MINUS)),
}


def add(a, b):
    return a[0] + b[0], a[1] + b[1]


def mul(a, b):
    return a[0]*b[0] - a[1]*b[1], a[0]*b[1] + a[1]*b[0]


def matmul(a, b):
    n = len(a)
    rows = []
    for i in range(n):
        row = []
        for j in range(n):
            value = ZERO
            for k in range(n):
                value = add(value, mul(a[i][k], b[k][j]))
            row.append(value)
        rows.append(tuple(row))
    return tuple(rows)


def tensor(a, b):
    return tuple(tuple(mul(x, y) for x in ar for y in br) for ar in a for br in b)


@lru_cache(None)
def operator(word):
    matrix = ((ONE,),)
    for letter in word:
        matrix = tensor(matrix, LITERAL[letter])
    return matrix


def identity(n, sign=1):
    return tuple(tuple((sign, 0) if i == j else ZERO for j in range(n)) for i in range(n))


def literal_graph(config):
    ops = [operator(w) for w in config["observables"]]
    adjacent = [set() for _ in ops]
    for i, a in enumerate(ops):
        for j in range(i):
            if matmul(a, ops[j]) != matmul(ops[j], a):
                adjacent[i].add(j)
                adjacent[j].add(i)
    return adjacent


def independently_enumerated_support(config):
    """Backtracking independent sets, then direct set-based even-neighbor tests."""
    graph = literal_graph(config)
    found = set()

    def visit(selected, available):
        if selected and all(len(neighbors.intersection(selected)) % 2 == 0 for neighbors in graph):
            found.add(frozenset(selected))
        while available:
            vertex = min(available)
            available.remove(vertex)
            visit(selected | {vertex}, available - graph[vertex])

    visit(set(), set(range(len(graph))))
    return found


class IndependentCertificateTests(unittest.TestCase):
    def test_literal_pauli_contexts(self):
        for config in [production.SQUARE, production.PENTAGRAM,
                       production.compose([production.SQUARE, production.SQUARE])]:
            ops = [operator(w) for w in config["observables"]]
            for context, sign in zip(config["contexts"], config["signs"]):
                result = identity(2**config["qubits"])
                for i in context:
                    for j in context:
                        self.assertEqual(matmul(ops[i], ops[j]), matmul(ops[j], ops[i]))
                    result = matmul(result, ops[i])
                self.assertEqual(result, identity(len(result), sign))

    def test_full_support_independent_matrix_and_set_route(self):
        for config in [production.SQUARE, production.PENTAGRAM,
                       production.compose([production.SQUARE, production.SQUARE])]:
            found = independently_enumerated_support(config)
            self.assertEqual(found, {frozenset(c) for c in config["contexts"]})

    def test_direct_seed_assignment_counts(self):
        expected = [{4: 96, 0: 320, -4: 96}, {3: 320, -1: 640, -5: 64}]
        for seed, wanted in zip([production.SQUARE, production.PENTAGRAM], expected):
            histogram = Counter()
            for assignment in itertools.product([-1, 1], repeat=len(seed["observables"])):
                score = 0
                for context, sign in zip(seed["contexts"], seed["signs"]):
                    value = sign
                    for v in context:
                        value *= assignment[v]
                    score += value
                histogram[score] += 1
            self.assertEqual(histogram, wanted)
            self.assertEqual(histogram, Counter(production.all_scores(seed)))

    def test_noise_against_enumerated_error_patterns(self):
        p = Fraction(1, 20)
        for seed in [production.SQUARE, production.PENTAGRAM]:
            config = production.compose([seed, seed])
            by_size = Counter(map(len, config["contexts"]))
            score = 0
            for r, count in by_size.items():
                mean = 0
                for errors in itertools.product([False, True], repeat=r):
                    flips = sum(errors)
                    probability = p**flips * (1-p)**(r-flips)
                    mean += (-1 if flips % 2 else 1) * probability
                score += count * mean
            self.assertEqual(score, production.noisy_quantum_score(seed["name"], 2, p))

    def test_validation_negative_controls(self):
        bad = copy.deepcopy(production.SQUARE)
        bad["contexts"].append(bad["contexts"][0])
        bad["signs"].append(bad["signs"][0])
        with self.assertRaisesRegex(AssertionError, "duplicate context"):
            production.validate(bad)
        bad = copy.deepcopy(production.SQUARE)
        bad["signs"][0] *= -1
        with self.assertRaisesRegex(AssertionError, "quantum context sign"):
            production.validate(bad)
        with self.assertRaises(ValueError):
            production.noisy_quantum_score("nonexistent-family", 1, Fraction(0))

    def test_optimized_python_is_rejected(self):
        result = subprocess.run([sys.executable, "-O", "-c", "import certificates"],
                                cwd=str(ROOT / "src"), capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("RuntimeError", result.stderr)


if __name__ == "__main__":
    unittest.main()

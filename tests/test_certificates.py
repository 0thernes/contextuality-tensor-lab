import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from certificates import *

class CertificateTests(unittest.TestCase):
    def test_zero_copies_boundary(self):
        self.assertEqual(exact_family("square", 0)["contexts"], 0)
        self.assertIsNone(exact_family("square", 0)["epsilon"])
        self.assertEqual(spectrum([]), {0: 1})

    def test_phase_sensitive_multiplication(self):
        self.assertEqual(multiply("XX", "ZZ"), (2, "YY"))
        self.assertEqual(multiply("XZ", "ZX"), (0, "YY"))
        self.assertNotEqual(multiply("X", "Y"), multiply("Y", "X"))

    def test_score_negative_endpoint(self):
        # Multiplying maxima alone is invalid for general signed spectra.
        # These seeds work because augmented absolute endpoints are bounded.
        sq, pent = all_scores(SQUARE), all_scores(PENTAGRAM)
        self.assertEqual(max(abs(s+1) for s in sq), max(sq)+1)
        self.assertEqual(max(abs(s+1) for s in pent), max(pent)+1)
        self.assertEqual(min(pent)+1, -4)

    def test_mixed_contexts(self):
        cfg = compose([SQUARE, PENTAGRAM])
        self.assertEqual(len(cfg["observables"]), 19)
        self.assertEqual(len(cfg["contexts"]), 41)
        self.assertTrue(validate(cfg))
        self.assertEqual(max(spectrum([SQUARE, PENTAGRAM])), 19)

    def test_exact_noise_endpoints(self):
        for kind in SEEDS:
            for k in [1, 2, 3]:
                self.assertEqual(noisy_quantum_score(kind, k, 0), exact_family(kind, k)["contexts"])
                self.assertEqual(noisy_quantum_score(kind, k, Fraction(1, 2)), 0)

if __name__ == "__main__":
    unittest.main()

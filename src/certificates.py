"""Exact, auditable contextuality certificates. Python standard library only.

No SAT solver or floating point is used to certify the finite classical optima.
Observable vertices stay disjoint; composition adds contexts, not observables.
"""
from collections import Counter
from itertools import product
from fractions import Fraction

if not __debug__:
    raise RuntimeError("Certificate checks require assertions: run Python without -O or -OO")

SQUARE = {
    "name": "square", "qubits": 2,
    "observables": ["XI", "IX", "XX", "IZ", "ZI", "ZZ", "XZ", "ZX", "YY"],
    "contexts": [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8]],
    "signs": [1, 1, 1, 1, 1, -1],
}
PENTAGRAM = {
    "name": "pentagram", "qubits": 3,
    "observables": ["XII", "IXI", "IIX", "YII", "IYI", "IIY", "XXX", "XYY", "YXY", "YYX"],
    "contexts": [[0, 1, 2, 6], [0, 4, 5, 7], [3, 1, 5, 8], [3, 4, 2, 9], [6, 7, 8, 9]],
    "signs": [1, 1, 1, 1, -1],
}
SEEDS = {s["name"]: s for s in [SQUARE, PENTAGRAM]}

# Entries are (power of i, result). This is ordinary matrix multiplication.
CYCLIC = {("X", "Y"): "Z", ("Y", "Z"): "X", ("Z", "X"): "Y"}

def multiply(a, b):
    assert len(a) == len(b)
    phase, letters = 0, []
    for x, y in zip(a, b):
        if x == "I": letters.append(y)
        elif y == "I": letters.append(x)
        elif x == y: letters.append("I")
        elif (x, y) in CYCLIC:
            phase += 1
            letters.append(CYCLIC[x, y])
        else:
            phase += 3
            letters.append(CYCLIC[y, x])
    return phase % 4, "".join(letters)

def commute(a, b):
    return multiply(a, b) == multiply(b, a)

def masks(config):
    return [sum(1 << v for v in c) for c in config["contexts"]]

def validate(config):
    obs, contexts, signs = (config[k] for k in ["observables", "contexts", "signs"])
    n = config["qubits"]
    assert len(set(obs)) == len(obs), "duplicate observable"
    assert all(len(o) == n and set(o) <= set("IXYZ") and o != "I"*n for o in obs)
    assert len(contexts) == len(signs)
    assert len(set(masks(config))) == len(contexts), "duplicate context"
    for c, sign in zip(contexts, signs):
        assert c and len(c) == len(set(c)) and all(0 <= j < len(obs) for j in c)
        assert sign in (-1, 1)
        assert all(commute(obs[i], obs[j]) for i in c for j in c), "incompatible context"
        phase, value = 0, "I"*n
        for j in c:
            p, value = multiply(value, obs[j])
            phase = (phase+p) % 4
        assert value == "I"*n and phase == (0 if sign == 1 else 2), "incorrect quantum context sign"
    return True

def compose(seeds):
    """Every nonempty tuple of empty/local contexts, with distinct original vertices."""
    n = sum(s["qubits"] for s in seeds)
    obs, options = [], []
    q_offset = 0
    for seed in seeds:
        offset = len(obs)
        obs.extend("I"*q_offset + o + "I"*(n-q_offset-seed["qubits"]) for o in seed["observables"])
        options.append([([], 1)] + [([v+offset for v in c], sign) for c, sign in zip(seed["contexts"], seed["signs"])])
        q_offset += seed["qubits"]
    contexts, signs = [], []
    for selected in product(*options):
        c, sign = [], 1
        for local, local_sign in selected:
            c.extend(local)
            sign *= local_sign
        if c:
            contexts.append(c)
            signs.append(sign)
    return {"name": "+".join(s["name"] for s in seeds), "qubits": n,
            "observables": obs, "contexts": contexts, "signs": signs}

def parity_table(n):
    p = bytearray(1 << n)
    for i in range(1, len(p)):
        p[i] = p[i >> 1] ^ (i & 1)
    return p

def all_scores(config):
    n = len(config["observables"])
    p, ms, sg = parity_table(n), masks(config), config["signs"]
    return [sum(s*(1-2*p[a & m]) for m, s in zip(ms, sg)) for a in range(1 << n)]

def hypergraph_support(config):
    """Independence and even-neighborhood criterion of Muller--Saniga Def.11.

    Exhaustively examines ALL vertex subsets, independent of compose().
    """
    obs = config["observables"]
    n = len(obs)
    neighbors = [sum(1 << j for j in range(n) if not commute(obs[i], obs[j])) for i in range(n)]
    kernel, independent = [0]*(1 << n), bytearray(1 << n)
    independent[0] = 1
    found = []
    for mask in range(1, 1 << n):
        bit = mask & -mask
        i, rest = bit.bit_length()-1, mask ^ bit
        kernel[mask] = kernel[rest] ^ neighbors[i]
        independent[mask] = independent[rest] and not (neighbors[i] & rest)
        if independent[mask] and kernel[mask] == 0:
            found.append(mask)
    return found

def spectrum(seeds):
    """Exact multiplicities by multiplying independent local augmented spectra."""
    counts = Counter({1: 1})
    for seed in seeds:
        local = Counter(s+1 for s in all_scores(seed))
        updated = Counter()
        for a, multiplicity in counts.items():
            for b, count in local.items():
                updated[a*b] += multiplicity*count
        counts = updated
    return Counter({s-1: count for s, count in counts.items()})

def exact_family(kind, k):
    assert kind in SEEDS and k >= 0
    m, a = (6, 5) if kind == "square" else (5, 4)
    contexts, bound = (m+1)**k-1, a**k-1
    return {"kind": kind, "copies": k, "qubits": SEEDS[kind]["qubits"]*k,
            "observables": len(SEEDS[kind]["observables"])*k,
            "contexts": contexts, "classical_bound": bound,
            "degree": (contexts-bound)//2,
            "epsilon": str(Fraction(contexts-bound, contexts)) if contexts else None}

def noisy_quantum_score(kind, k, p):
    """Independent outcome flips, p in [0,1/2], exact rational score."""
    if kind not in SEEDS:
        raise ValueError("unknown seed family: " + str(kind))
    p = Fraction(p)
    assert 0 <= p <= Fraction(1, 2) and k >= 0
    m, r = (6, 3) if kind == "square" else (5, 4)
    return (1+m*(1-2*p)**r)**k-1

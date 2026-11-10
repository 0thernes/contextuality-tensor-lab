# Moonlab browser distribution

The `moonlab/` directory contains the unmodified prebuilt Moonlab JavaScript
and WebAssembly distribution from Tsotchke's repository, pinned to commit
`cd3b2347e3739327548708073d7e4ac710cc6a6c` (upstream version 1.2.1).

Upstream: https://github.com/tsotchke/moonlab

The original MIT [LICENSE](moonlab/LICENSE) is retained, together with the
[provenance record](moonlab/PROVENANCE.md) inherited from the user's Hoggar Bound
Lab project. References in that inherited record to the earlier project's
scripts do not identify files in this project.

The browser adapter performs basis rotations using Moonlab's native gate
functions. Moonlab itself performs projective measurements and state collapse.
The adapter reads a pinned WASM state structure for an independent expectation
oracle; the amplitudes pointer is at byte offset 8. Browser randomness is the
explicitly seeded xorshift32 sampler in `moonlab_live.mjs`. It is not the offline
Tsotchke QRNG component and is not a physical entropy source.

This is a classical CPU simulation. No hardware quantum measurement, hardware
randomness or quantum computational advantage is claimed.

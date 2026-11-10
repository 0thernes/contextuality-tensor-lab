# Pinned Tsotchke components

These files are copied byte-for-byte from the user's existing Hoggar Bound Lab
checkout on 9 November 2026. Their original `PROVENANCE.md` records are retained
as provenance from that earlier project. References in those records to its
scripts or audit results describe Hoggar Bound Lab, not files in this new lab.
The new lab's own executable integration is `../scripts/run_stack.py` and its
current evidence is `../results/stack_report.json`.

| Component | Recorded upstream commit | New lab use |
| --- | --- | --- |
| Moonlab | `cd3b2347e3739327548708073d7e4ac710cc6a6c` | Actual CPU/WASM state preparation, gates, Born draws and projective collapse |
| quantum_geometric_tensor | `770994aa8ddd858e6bb16eebb25250a7b9f67c96` | Actual C Fubini–Study and Berry-curvature kernels on normalized pure states |
| quantum_rng | `1a77e77f803c63883349b658361c06401cd8ceb7` | Legacy seeded software byte stream, used for measurement draws and context selection |

The per-component MIT licenses are retained. The one QGTL compatibility shim,
`qgtl/stub/cblas.h`, is locally supplied and labeled as such. None of the compiled
geometry functions call BLAS. Moonlab's prebuilt binary has not been independently
rebuilt from its compiler toolchain. The wrapper is deliberately coupled to that
binary's documented state layout; its amplitudes pointer is at byte offset 8.

`SHA256SUMS.json` fixes the imported implementation and license bytes. The runner
checks these hashes before executing anything. A different toolchain can change
the seeded QRNG byte stream because it uses floating-point math; certificates
must remain independently verifiable regardless of which stream was used.

All execution here is classical software. There is no physical quantum random
source, quantum device, GPU/distributed-QGTL demonstration or quantum speedup.

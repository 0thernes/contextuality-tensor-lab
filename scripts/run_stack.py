"""Build and exercise actual Tsotchke components. All four are required.

python scripts/run_stack.py [--seed INTEGER]
Set ESHKOL_RUN on nonstandard installations. No hardware execution is claimed.
"""
import argparse
import ctypes as ct
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import time
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
BUILD, RESULTS = ROOT / 'build', ROOT / 'results'


def require(value, message):
    if not value:
        raise AssertionError(message)


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def run(args, label, env=None):
    result = subprocess.run([str(x) for x in args], cwd=ROOT, env=env,
                            text=True, encoding='utf-8', errors='replace', capture_output=True)
    (RESULTS / ('stack_' + label + '.log')).write_text(
        result.stdout + result.stderr, encoding='utf-8')
    if result.returncode:
        raise RuntimeError('%s failed (%s): %s' % (label, result.returncode,
                                                 (result.stdout + result.stderr)[-3000:]))
    return result.stdout


def qgtl():
    dll = BUILD / ('stack_diffgeo.dll' if os.name == 'nt' else 'stack_diffgeo.so')
    command = ['gcc', '-O2', '-std=gnu11', '-shared', '-fPIC',
               '-Ithird_party/qgtl/include', '-Ithird_party/qgtl/stub',
               'third_party/qgtl/src/quantum_geometric/distributed/differential_geometry.c',
               '-o', dll, '-lm']
    run(command, 'qgtl_build')
    dll_directory = None
    if os.name == 'nt':
        dll_directory = os.add_dll_directory(str(Path(shutil.which('gcc')).parent))
    lib = ct.CDLL(str(dll))
    lib.diffgeo_engine_create.restype = ct.c_void_p
    lib.diffgeo_engine_destroy.argtypes = [ct.c_void_p]
    for name in ['diffgeo_compute_fubini_study', 'diffgeo_compute_berry_curvature']:
        fn = getattr(lib, name)
        fn.argtypes = [ct.c_void_p, ct.c_void_p, ct.c_size_t, ct.c_void_p,
                       ct.c_size_t, ct.c_void_p]
        fn.restype = ct.c_bool
    engine = lib.diffgeo_engine_create()
    require(engine, 'QGTL engine allocation')

    def kernels(state, tangents):
        state = np.ascontiguousarray(state, dtype=np.complex128)
        tangents = np.ascontiguousarray(tangents, dtype=np.complex128)
        n = len(tangents)
        g, f = np.zeros((n, n)), np.zeros((n, n))
        for name, out in [('diffgeo_compute_fubini_study', g),
                          ('diffgeo_compute_berry_curvature', f)]:
            ok = getattr(lib, name)(engine, state.ctypes.data, state.size,
                                   tangents.ctypes.data, n, out.ctypes.data)
            require(ok, name + ' returned false')
        return g, f

    data = json.loads((RESULTS / 'stack_tangents.json').read_text())
    state = np.array(data['state']) @ np.array([1, 1j])
    tangents = np.array(data['tangents']) @ np.array([1, 1j])
    require(abs(np.vdot(state, state) - 1) < 1e-12, 'Moonlab state normalized')
    g, f = kernels(state, tangents)
    overlaps = tangents.conj() @ state
    q = tangents.conj() @ tangents.T - np.outer(overlaps, overlaps.conj())
    g_ref, f_ref = q.real, -2 * q.imag
    analytic_g = np.zeros((8, 8))
    analytic_f = np.zeros((8, 8))
    for j, theta in enumerate(data['parameters'][:4]):
        analytic_g[j, j] = 0.25
        analytic_g[j+4, j+4] = np.sin(theta)**2 / 4
        analytic_f[j, j+4] = -np.sin(theta) / 2
        analytic_f[j+4, j] = np.sin(theta) / 2
    reference_error = float(max(np.max(abs(g-g_ref)), np.max(abs(f-f_ref))))
    analytic_error = float(max(np.max(abs(g-analytic_g)), np.max(abs(f-analytic_f))))
    require(reference_error < 1e-12, 'QGTL reference mismatch')
    require(analytic_error < 1e-9, 'Moonlab/QGTL product-sphere analytic metric mismatch')
    shifted = tangents + 1j * np.arange(1, 9)[:, None] * state[None, :]
    gg, ff = kernels(state, shifted)
    gauge_error = float(max(np.max(abs(gg-g)), np.max(abs(ff-f))))
    require(gauge_error < 1e-11, 'QGTL gauge invariance')
    # Negative control: wrong Berry sign convention must disagree materially.
    wrong_sign_error = float(np.max(abs(f+analytic_f)))
    require(wrong_sign_error > 0.9, 'Berry sign mutation was not detected')
    lib.diffgeo_engine_destroy(engine)
    return {'status': 'pass', 'source': 'Actual pinned Tsotchke differential_geometry.c',
            'kernels': ['diffgeo_compute_fubini_study', 'diffgeo_compute_berry_curvature'],
            'state_dimension': 16, 'parameters': 8,
            'state_preparation': 'Four Ry(theta) then Rz(phi) local rotations followed by a fixed three-CNOT entangler, all executed in Moonlab',
            'tangent_source': 'Central differences of native Moonlab-prepared amplitudes',
            'difference_step': data['step'],
            'analytic_metric': 'g_theta_j,theta_j=1/4, g_phi_j,phi_j=sin(theta_j)^2/4; other entries zero',
            'analytic_curvature': 'F_theta_j,phi_j=-sin(theta_j)/2; antisymmetric transpose; other entries zero',
            'max_direct_inner_product_error': reference_error,
            'max_analytic_error': analytic_error, 'max_gauge_error': gauge_error,
            'wrong_berry_sign_max_error': wrong_sign_error,
            'metric': g.tolist(), 'berry_curvature': f.tolist(),
            'binary_sha256': sha(dll), 'build_command': [str(x) for x in command],
            'scope': 'Normalized pure-state geometry kernels only. No QGTL GPU/distributed execution or validation.'}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--seed', type=int, default=20261109)
    args = parser.parse_args()
    require(0 <= args.seed <= 2**53-1, 'Seed must be an exactly representable nonnegative JS integer')
    BUILD.mkdir(exist_ok=True)
    RESULTS.mkdir(exist_ok=True)
    started = time.monotonic()
    pins = json.loads((ROOT/'third_party/SHA256SUMS.json').read_text())
    for rel, expected in pins.items():
        require(sha(ROOT/'third_party'/rel) == expected,
                'Pinned vendor file changed: ' + rel)
    exe = BUILD / ('stack_qrng.exe' if os.name == 'nt' else 'stack_qrng')
    run(['gcc', '-O2', '-std=gnu11', 'src/stack_qrng.c',
         'third_party/quantum_rng/src/quantum_rng/quantum_rng.c',
         '-Ithird_party/quantum_rng/src/quantum_rng', '-o', exe, '-lm'], 'qrng_build')
    first = run([exe, args.seed, 4096], 'qrng_first')
    second = run([exe, args.seed, 4096], 'qrng_repeat')
    different = run([exe, args.seed+1, 4096], 'qrng_other_seed')
    require(first == second and first != different and len(bytes.fromhex(first)) == 4096,
            'QRNG seeded software stream reproducibility')
    print('PASS QRNG actual seeded software generator', flush=True)
    run(['node', 'src/stack_moonlab.mjs', args.seed], 'moonlab_run')
    moonlab = json.loads((RESULTS/'stack_moonlab.json').read_text())
    print('PASS Moonlab native four-qubit gates and joint measurements', flush=True)
    qgt = qgtl()
    print('PASS QGTL native geometry on Moonlab parameterized states', flush=True)
    eshkol = os.environ.get('ESHKOL_RUN') or shutil.which('eshkol-run')
    require(eshkol and Path(eshkol).is_file(), 'ESHKOL_RUN or eshkol-run executable required')
    env = os.environ.copy()
    if os.name == 'nt' and Path('Z:/Tools/LLVM-21/bin/clang++.exe').is_file():
        env.update(ESHKOL_CXX_COMPILER='Z:/Tools/LLVM-21/bin/clang++.exe',
                   LLVM_HOME='Z:/Tools/LLVM-21',
                   ESHKOL_CUDA_LIBRARY_PATH='Z:/Tools/cuda-12.9-redist/lib/x64',
                   CUDA_HOME='Z:/Tools/cuda-12.9-redist')
        env['PATH'] = 'Z:/Tools/cuda-12.9-redist/bin;' + env['PATH']
    output = run([eshkol, '-r', 'src/stack_enumeration.esk'], 'eshkol', env)
    exact = json.loads(next(line for line in output.splitlines() if line.startswith('{')))
    require(exact.get('pass') is True, 'Eshkol exact enumeration failed')
    print('PASS Eshkol exhaustive integer enumeration', flush=True)
    source_paths = sorted(list((ROOT/'third_party').rglob('*')) +
                          list((ROOT/'src').glob('stack_*')) + [Path(__file__).resolve()])
    hashes = {str(p.relative_to(ROOT)).replace('\\', '/'): sha(p)
              for p in source_paths if p.is_file()}
    report = {'status': 'pass', 'classification': 'Classical software experiment with exact finite mathematics; no quantum hardware',
              'elapsed_seconds': time.monotonic()-started, 'platform': platform.platform(),
              'python': sys.version.split()[0], 'numpy': np.__version__,
              'verified_vendor_files': len(pins),
              'node': run(['node', '--version'], 'node_version').strip(),
              'gcc': run(['gcc', '--version'], 'gcc_version').splitlines()[0],
              'qrng': {'status': 'pass', 'seed': args.seed, 'same_build_repeat_identical': True,
                       'different_seed_differs': True, 'stream_4096_sha256': hashlib.sha256(bytes.fromhex(first)).hexdigest(),
                       'classification': 'Seeded classical quantum-inspired software mixer'},
              'moonlab': moonlab, 'qgtl': qgt,
              'eshkol': {'status': 'pass', 'version': run([eshkol, '--version'], 'eshkol_version').strip(),
                         'executable_sha256': sha(eshkol), 'exact_enumeration': exact},
              'source_sha256': hashes}
    (RESULTS/'stack_report.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    print('ALL FOUR TSOTCHKE COMPONENTS PASSED', flush=True)


if __name__ == '__main__':
    main()

# Dwell-Fiber Overview

## What is Dwell-Fiber?

Dwell-Fiber is a minimal, end-to-end prototype that turns the **Network-Utility-Maximisation (NUM) fibre-bundle model** of compiler passes into **runnable eBPF/LLVM/K8s artefacts**. It continuously rewrites system-call traces to **minimise ransomware dwell-time** while exposing **dual prices** that can be consumed by any other layer (OS scheduler, pod autoscaler, silicon power governor).

The same 300-line core—instantiated through **sigil remapping**—has already been reused for ATP-budgeted metabolic edits and cache-constrained thread placement, proving the "same math, different fibre" claim.

## Academic Lineage

The codebase is a concrete realisation of the **fibered-functor compiler framework** introduced in:

> "From Pass = NUM to Compiler = Fibered Functor" – Moonshot AI technical memo (2025)  
> [View the full memo](../docs/memo-fibered-compiler-2025.pdf)

This work unifies several important theoretical strands:

1. **NUM compilers** – Kelly, Maulloo & Tan (1998) "Rate control for communication networks" extended to compiler optimisation spaces.
2. **Convex-resource passes** – Büttner & Malloy (2020) "Polyhedral optimisations as convex games".
3. **Proof-carrying code** – Necula & Lee (1997) "Safe kernel extensions without run-time checks".
4. **Category-theoretic rewriting** – Ehrig et al. (2006) "Graph-transformations as functor categories".

The memo demonstrates that every pass is a **contravariant fibered functor**:  
F : (Syntax/Behaviours)ᵒᵖ → ℝ≥0  
over the base category of **resource budgets** ℝ≥0ᵏ.

**Strong duality** holds whenever the per-pass utility is concave—exactly the case for:
- Dwell-time (negative convex)
- Register pressure (sub-modular)
- ATP flux (linear)

## System Components

| Layer | Artefact | Function |
|---|---|---|
| **eBPF kernel** | `dwell_kern.c` | Per-task taint clock; kills process when `dwell > budget`; exports `price_dwell` map. |
| **Userspace daemon** | `dwell_user.go` | ADMM dual ascent: `π ← [π + α(dwell – r)]⁺`; 800 ns per syscall on i7-1260P. |
| **LLVM pass** | `lib/DwellPass.cpp` | Instruments IR with `dwell_update()`; same price variable linked at run-time. |
| **K8s autoscaler** | `config/hpa.yaml` | Custom metric `dwell_seconds_current`; scales pods to keep average ≤ 5 s. |
| **Stability proof** | `proofs/dwell_stable.v` | Coq lemma: chordal dependence graph ⇒ bounded Lyapunov drift; 180 ms check. |

For detailed architecture information and component interactions, see [architecture.md](architecture.md).

## Performance Characteristics

- Syscall overhead: 800 ns per call (i7-1260P)
- Coq proof verification: 180 ms
- K8s autoscaling response: sub-second

For detailed performance analysis and reproduction steps, see [performance.md](performance.md).
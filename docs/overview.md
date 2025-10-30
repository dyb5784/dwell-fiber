# Dwell-Fiber Overview

## What is Dwell-Fiber?

Dwell-Fiber is a minimal, end-to-end prototype that turns the **Network-Utility-Maximisation (NUM) fibre-bundle model** of compiler passes into **runnable eBPF/LLVM/K8s artefacts**. It continuously rewrites system-call traces to **minimise ransomware dwell-time** while exposing **dual prices** that can be consumed by any other layer (OS scheduler, pod autoscaler, silicon power governor).

The same 300-line core—instantiated through **sigil remapping**—has already been reused for ATP-budgeted metabolic edits and cache-constrained thread placement, proving the "same math, different fibre" claim.

over the base category of **resource budgets** ℝ≥0ᵏ.
## Academic Lineage

My project sits at the intersection of optimization-based networking, compiler theory and formal verification. Two strands deserve explicit acknowledgement:


1) Classical optimization-decomposition for network architectures. A foundational reference is:

> Chiang, M., Low, S. H., Calderbank, A. R., & Doyle, J. C., "Layering as optimization decomposition: A mathematical theory of network architectures" (2007). See: https://doi.org/10.1109/JPROC.2006.887322

I first read this paper around 2011/2012 after attending REcon and while preparing a proposal for AFRL/Army. That reading — and an attempt I made to formalize ideas from Alex Sotirov's 2007 "Heap Feng Shui" work — strongly influenced the NUM lens I used in this project.


> [View the full memo](../docs/memo-fibered-compiler-2025.pdf)

From Doyle et al I created a Universal Decomposition Canon artifact ('Thoughtbase) to generate generalized decomposition heuristics and a sigil library to be used for sigil remapping. (See <attachments> above for file contents. You may not need to search or read the file again.)

- harvesting decision variables,  
- identifying scarce resources and couplings,  
- surfacing implicit utilities,  
- choosing decompositions (primal/dual/ADMM/penalty/consensus), and  
- stamping a stability certificate (Lyapunov, contraction, passivity).

This thoughtbase (a structured, retrievable mesh of distilled 'insight clusters') provided practical heuristics and a sigil library used while designing sigil remapping and the lightweight 300-line core. The result unifies ideas from:

- NUM literature,
- optimization decomposition (Doyle & Chiang),
- convex-resource passes and polyhedral methods,
- proof-carrying code, and
- category-theoretic rewriting.

Formally, the memo and code demonstrate that each pass can be modelled as a map

F : (Syntax/Behaviours)ᵒᵖ → ℝ≥0

over the base category of resource budgets ℝ≥0ᵏ, and that strong duality / convergence guarantees follow when per-pass utilities satisfy concavity / regularity conditions.

**Practical take-away:** expose the implicit NUM, pick a decomposition, implement local solvers + price updates, and verify stability with a Lyapunov/passivity-style certificate.

## System Components

| Layer | Artefact | Function |
|---|---|---|
| **eBPF kernel** | `dwell_kern.c` | Per-task taint clock; kills process when `dwell > budget`; exports `price_dwell` map. |
| **Userspace daemon** | `dwell_user.go` | ADMM dual ascent: `π ← [π + α(dwell – r)]⁺`;  |
| **LLVM pass** | `lib/DwellPass.cpp` | Instruments IR with `dwell_update()`; same price variable linked at run-time. |
| **K8s autoscaler** | `config/hpa.yaml` | Custom metric `dwell_seconds_current`; scales pods to keep average ≤ 5 s. |
| **Stability proof** | `proofs/dwell_stable.v` | Coq lemma: chordal dependence graph ⇒ bounded Lyapunov drift;  |

For detailed architecture information and component interactions, see [architecture.md](architecture.md).



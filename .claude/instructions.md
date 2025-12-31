Coq conventions used in this repo
- Import namespace: From Coq Require Import ssreflect ssrbool.
- We use boolean reflection: destruct (x <=? y) eqn:H.
- Custom tactics: bdestruct, lia, bv_omega (bit-vector).
- Key lemmas available in ./coq-signatures.md; ask for them by name.
- When a proof fails, first suggest using bdestruct or lia before escalating.
- Do NOT paste whole proof scripts; quote ≤5-line snippets.

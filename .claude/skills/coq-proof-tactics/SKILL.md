---
name: coq-proof-tactics
version: 1.0.0
description: Suggest proof tactics for Coq proofs in Dwell-Fiber project following repository conventions
parameters:
  goal_type:
    type: string
    description: Type of proof goal (inequality, list_property, real_arithmetic, etc.)
---

# Coq Proof Tactics for Dwell-Fiber

## Purpose

Suggests appropriate proof tactics for Coq proof goals based on Dwell-Fiber project conventions and standard Coq libraries.

## Repository Conventions

From `.claude/instructions.md`:
- Import namespace: `From Coq Require Import ssreflect ssrbool.`
- Boolean reflection: `destruct (x <=? y) eqn:H.`
- Custom tactics: `bdestruct`, `lia`, `bv_omega` (bit-vector)
- When a proof fails, first suggest `bdestruct` or `lia`
- Quote ≤5-line snippets to avoid overwhelming context

## Common Tactics by Goal Type

### 1. Inequalities (R, nat, Z)

**Goal**: `a <= b`, `a < b`, `a >= b`

```coq
(* For real numbers *)
unfold Rle, Rlt.  (* Expand definitions *)
lra.             (* Linear real arithmetic *)
psatz R.         (* Polynomial constraints *)

(* For natural numbers *)
lia.             (* Linear integer arithmetic *)

(* Destruct boolean comparisons *)
destruct (a <=? b) eqn:H.
+ (* Case a <= b *)
+ (* Case a > b *)
```

### 2. List Properties

**Goal**: List length, membership, filtering

```coq
simpl.                     (* Simplify list expressions *)
induction l.               (* Induction on list *)
- (* Base case *)
- (* Inductive case *)

(* For list operations *)
rewrite -> list_filter_spec.
apply in_or_app.
```

### 3. Event Stream Properties (Dwell-Fiber specific)

**Goal**: `total_dwell stream`, event loss patterns

```coq
unfold total_dwell.        (* Expand dwell calculation *)
induction stream.          (* Structural induction on stream *)
- (* Empty stream *)
- (* Event :: rest *)
  simpl.
  lra.

(* For apply_loss *)
destruct pattern eqn:H.
+ (* Keep case *)
  simpl. apply IH.
+ (* Drop case *)
  simpl. assumption.
```

### 4. Arithmetic Expressions

**Goal**: Complex arithmetic with `+`, `*`, `-`

```coq
ring_simplify.             (* Simplify ring expressions *)
field_simplify.            (* Simplify field expressions *)

(* With hypotheses *)
replace (a + b) with c by lra.
rewrite H.                 (* Use existing hypothesis *)
```

### 5. Propositional Logic

**Goal**: `A /
B`, `A \/
B`, `A -> B`

```coq
split.                     (* Split conjunction *)
- (* First subgoal *)
- (* Second subgoal *)

left.  (* Choose left for disjunction *)
right. (* Choose right for disjunction *)

intros H.                  (* Introduce implication hypothesis *)
```

### 6. Universal/Existential Quantifiers

**Goal**: `forall x, P(x)`, `exists x, P(x)`

```coq
intros x.                  (* Introduce forall variable *)

(* For exists *)
exists 0.                  (* Provide witness *)
prove_property.

(* Complex quantifier patterns *)
intros n [H1 H2].          (* Destruct existential hypothesis *)
```

## Dwell-Fiber Specific Patterns

### Price Update Properties

```coq
(* From dwell_stable.v *)
Theorem price_nonnegative :
  forall p d, 0 <= p -> 0 <= p + alpha * (d - budget).
Proof.
  intros p d Hp.          (* Introduce variables and hypothesis *)
  lra.                    (* Linear arithmetic solves *)
Qed.

Theorem price_bounded : ...
(* Use: unfold price_update; lra. *)
```

### Event Loss Resilience

```coq
(* From dwell_kernel_resilience.v *)
Theorem bounded_loss_preserves_dwell_bound : ...
Proof.
  intros s pat Hvalid Hbound.  (* Stream, pattern, validity, original bound *)
  induction s.                 (* Induction on event stream *)
  - (* Base: empty stream *)
    simpl. constructor.
  - (* Inductive: event :: stream *)
    simpl. destruct pat eqn:Hpat.
    + (* Keep case *)
      apply IHs.
    + (* Drop case *)
      lra.
Qed.
```

## Debugging Failed Proofs

### Common Issues

1. **Too complex for automation**
   ```coq
   (* Instead of: *)
   lra.  (* Fails *)
   
   (* Try: *)
   unfold Rminus, Rdiv.  (* Expand definitions *)
   ring_simplify.        (* Simplify *)
   lra.                  (* Now succeeds *)
   ```

2. **Missing hypothesis**
   ```coq
   (* Check context with: *)
   Show.  (* Or just look at goal state *)
   
   (* State what you expect to see: *)
   (* "The context should contain H: a <= b" *)
   ```

3. **Induction needed**
   ```coq
   (* Before: *)
   simpl. lra.  (* Fails *)
   
   (* After: *)
   induction stream.  (* Structural induction *)
   - simpl. lra.      (* Base case *)
   - simpl. lra.      (* Inductive case *)
   ```

## Custom Tactics in Dwell-Fiber

### `bdestruct` (Boolean Destruction)
- Usage: `bdestruct (x <=? y).`
- Automatic boolean reflection with equation naming

### `bv_omega` (Bit-vector)
- For bit-vector operations
- Rare in current proofs

### `lia` (Linear Integer Arithmetic)
- For nat and Z arithmetic
- More robust than `omega`

## Proof Structure Best Practices

1. **State the approach first**
   ```coq
   (* We prove this by induction on the stream structure *)
   induction stream.
   ```

2. **Use bullets for clarity**
   ```coq
   - (* Base case *)
     simpl. lra.
   - (* Inductive case *)
     simpl. destruct pattern.
     + (* Keep *) apply IH.
     + (* Drop *) lra.
   ```

3. **Document non-trivial steps**
   ```coq
   (* Since loss rate ≤ delta, we have: *)
   apply Hvalid.
   lra.
   ```

## Token-Efficient Responses

When suggesting proofs:
- Show ≤5 lines of code
- Use `(* ... *)` for omitted parts
- Explain the reasoning verbally

**Example**:
```coq
Theorem example : ...
Proof.
  intros x y H.           (* Introduce variables *)
  destruct (x <=? y) eqn:Hxy.  (* Case analysis *)
  - (* Case x ≤ y *)
    lra.                  (* Linear arithmetic *)
  - (* Case x > y *)
    (* Use hypothesis H and the inequality *)
    lra.
Qed.
```

## Quick Reference

| Goal Type | First Try | Second Try | Special Notes |
|-----------|-----------|------------|---------------|
| R equations | `lra` | `field_simplify; lra` | For division |
| nat/Z equations | `lia` | `ring_simplify; lia` | For powers |
| List properties | `induction` | `simpl; rewrite` | Structural induction |
| Boolean tests | `bdestruct` | `destruct ... eqn:` | Boolean reflection |
| Complex expressions | `unfold` | `simpl` | Expand definitions |

## Related Files

- **Coq proofs**: `coq/dwell_stable.v`, `coq/dwell_kernel_resilience.v`
- **Installation**: `COQ_INSTALLATION.md`
- **Signatures**: `coq-signatures.md` (for lemma lookup)
- **Verification scripts**: `verify-proofs.sh`, `verify-coq-installation.sh`

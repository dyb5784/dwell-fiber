---
name: coq-bugfix
version: 1.0.0
description: Analyze and fix common Coq proof errors in Dwell-Fiber proofs
parameters:
  error_type:
    type: string
    description: Type of Coq error (type_mismatch, unknown_tactic, unresolved_variables, etc.)
---

# Coq Bug-Fixing Assistant for Dwell-Fiber

## Purpose

Analyzes Coq compilation errors and proof failures, then provides specific fixes following Dwell-Fiber project conventions and Coq best practices.

## Common Coq Errors and Fixes

### 1. Type Mismatch / Type Error

**Symptom**:
```
Error: In environment
...
The term "X" has type "T" while it is expected to have type "U".
```

**Analysis**:
- Coq found term `X` with type `T` but context expects type `U`
- Usually due to implicit coercions, missing conversions, or logic errors

**Fixes**:

```coq
(* Option 1: Explicit type cast if available *)
exact (X : U).

(* Option 2: Use appropriate conversion lemma *)
apply Rle_trans with (r2 := intermediate_value).

(* Option 3: Fix the hypothesis *)
replace T with U by (
  unfold T, U; lra
).
```

**Prevention**:
- Use explicit type annotations: `(expr : type)`
- Check implicit arguments with `Set Implicit Arguments.`
- Use `Check term.` to inspect types before use

### 2. Unknown Tactic or Tactical

**Symptom**:
```
Error: Unknown tactic: foo_tactic.
```

**Analysis**:
- Tactic name is misspelled or not imported
- Common with MathComp tactics requiring specific imports

**Fixes**:

```coq
(* Add required imports at top of file *)
From Coq Require Import ssreflect ssrbool.
From mathcomp Require Import all_ssreflect.

(* Use standard tactics instead *)
(* Instead of: foo_tactic. *)
(* Use: bdestruct. *)

(* Check available tactics: *)
Search "lra".  (* Search for linear real arithmetic tactics *)
```

**Common Dwell-Fiber Tactic Imports**:
```coq
Require Import Reals.
Require Import List.
Require Import Lia.
Require Import Lra.
Require Import Psatz.
```

### 3. Unresolved Variables / Existential Variables

**Symptom**:
```
Error:
In environment
...
Cannot infer this placeholder of type "nat".
```

**Analysis**:
- Coq cannot infer implicit arguments
- Missing explicit witness for existential quantifiers
- Incomplete tactic application

**Fixes**:

```coq
(* Provide explicit arguments *)
apply my_lemma with (n := 5) (x := 0.5).

(* Or use @ to make all arguments explicit *)
apply @my_lemma.

(* Provide witness for existential *)
exists 0.  (* Instead of just: exists. *)

(* Use eapply for partial application *)
eapply my_lemma.
```

### 4. Proof Not Finished / Unfinished Proof

**Symptom**:
```
Error: Attempt to save an incomplete proof.
```

**Analysis**:
- `Qed.` or `Defined.` reached before all subgoals solved
- Missing tactic application

**Fixes**:

```coq
(* Check remaining goals: *)
Show.  (* See current goal state *)

(* Solve remaining goals: *)
all: try lra.           (* Try lra on all remaining goals *)
all: try assumption.    (* Try assumption on remaining goals *)

(* Or handle specific goals: *)
{ (* First subgoal *) lra. }
{ (* Second subgoal *) simpl; lra. }
```

### 5. Cannot Find Instance / Type Class Error

**Symptom**:
```
Error: Cannot find an instance for: "...".
```

**Analysis**:
- Type class instance missing
- Common with `comparable`, `eqType`, etc. from MathComp

**Fixes**:

```coq
(* Add proper type class instances *)
Require Import Classes.RelationClasses.

(* Or avoid type classes with concrete types *)
(* Instead of generic type, use concrete: nat, R, etc. *)

(* Import necessary libraries for type class support *)
From mathcomp Require Import eqtype.
```

### 6. Error on Qed / Axiom Admitted

**Symptom**: `Warning: Axiom foo is declared without a body.`

**Analysis**:
- `Admitted.` used to skip proof creation
- Insecure for production verification

**Fixes**:

```coq
(* Replace Admitted with actual proof: *)
Lemma important_property : ...
Proof.
  (* ... proof steps ... *)
  lra.
Qed.  (* Replace: Admitted. *)

(* If genuinely unprovable, extract as Parameter: *)
Parameter unprovable_assumption : ...
```

### 7. Ring/Field Operation Error

**Symptom**:
```
Error: not a valid ring equation.
```

**Analysis**:
- Terms not in valid ring/field structure
- Wrong tactic for expression type

**Fixes**:

```coq
(* Try ring_simplify instead of ring *)
ring_simplify.

(* Use field for rational expressions *)
field_simplify.

(* Expand definitions first *)
unfold Rminus, Rdiv.
ring_simplify.
```

### 8. Abstracting over Multiple Goals

**Symptom**:
```
Error: Abstracting over too many goals. Use { } brackets.
```

**Analysis**:
- Multiple subgoals after tactic application
- Need focused proof structure

**Fixes**:

```coq
(* Use bullet points and brackets *)
- (* First main goal *)
  { (* Subgoal 1 *) lra. }
  { (* Subgoal 2 *) simpl; lra. }

(* Or use different levels: *)
+ (* Goal at + level *)
  { (* Subgoal *) }
++ (* Different branch *)
```

## Coq Compilation Debugging

### Step 1: Identify Error Location

```bash
# Run coqc with verbose output
coqc -R . DwellFiber -verbose dwell_stable.v

# Or use the enhanced script with debug flag
./scripts/coq-verify-enhanced.sh --verbose
```

### Step 2: Isolate the Problem

1. **Comment out sections** until it compiles
2. **Work backwards** to find the problematic lemma
3. **Check dependencies**: Does this lemma depend on a previous axiom?

### Step 3: Use CoqIDE/ProofGeneral

```coq
(* Set debug options for more info *)
Set Printing All.
Set Debug Tactic Unification.

(* After fix, reset to normal *)
Unset Printing All.
```

## Dwell-Fiber Specific Issues

### Type Issues with Proofs

When you see:
```
Error: The term has type "Type" while it is expected to have type "Prop".
```

**Fix**: Add explicit universe annotations
```coq
Set Universe Polymorphism.
```

### Real Number Equivalence

```coq
(* Don't use: *)
Require Import Coq.Reals.RIneq.
Require Import Reals.RIneq.  (* Conflict! *)

(* Use only: *)
Require Import Reals.
```

### Event Stream Induction

Common pitfall: Induction hypothesis not general enough

```coq
(* Wrong: induction stream. *)
(* Right: induction stream as [|e s']. *)
```

## Auto-Fix Strategy

For each error, this skill will:

1. **Analyze error message** to classify error type
2. **Suggest 2-3 specific fixes** with code examples
3. **Explain why the error occurred**
4. **Provide prevention tips**
5. **Link to related lemmas** if relevant

**Example Workflow**:

User: "Coq error: Unknown tactic bdestruct."

Skill response:
```
This means the `bdestruct` tactic is not available, likely because:
1. The tactic is from SSR (Ssreflect) which isn't imported
2. It's not in your Coq environment

Quick fixes:

**Fix 1**: Use standard boolean destruct (always available)
```coq
destruct (x <=? y) eqn:H.  (* Instead of: bdestruct (x <=? y). *)
```

**Fix 2**: Import ssreflect at top
```coq
From Coq Require Import ssreflect ssrbool.
bdestruct (x <=? y).
```

**Fix 3**: Use lia for inequalities after destruct
```coq
destruct (x <=? y); try lia.  (* Solves both cases automatically *)
```

Recommendation: Use Fix 1 for compatibility.
```

## Related Resources

- **Coq Reference Manual**: https://coq.inria.fr/refman/
- **Coq Proof Assistant Help**: `coqc -help`
- **Dwell-Fiber Coq proofs**: `coq/`
- **Installation guide**: `COQ_INSTALLATION.md`
- **Lemma signatures**: `coq-signatures.md`

## Emergency Recovery

If proofs are completely broken:

1. **Checkout last working version**
```bash
git stash
git checkout HEAD~1 -- coq/
```

2. **Rebuild from scratch**
```bash
make clean
make coq
```

3. **Bisect to find breaking change**
```bash
git bisect start
# Test commits until finding the issue
```

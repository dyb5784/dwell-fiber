---
name: coq-lemma-fetch
description: Retrieves lemma statement + 3-line mini-proof sketch from local coq-signatures.md when user says "lemma foo" or "how did we prove X".
---

# Coq Lemma Fetch Skill

## Purpose
Quick lookup of lemma/theorem declarations and proof sketches (~200 tokens).

## Instructions

When user requests a specific lemma or theorem (e.g., "lemma price_nonnegative", "how did we prove bounded_loss_preserves_dwell_bound"):

1. **Run the command** with the lemma name as argument
2. **Present the output** showing:
   - Lemma/theorem name
   - Declaration signature
   - First few lines of proof tactics
3. **Offer**: "Want to see the full proof in the .v file?"

## Command

```bash
grep -i -A 8 "^### $1$" coq-signatures.md | head -15
```

## Usage Examples

```bash
# Fetch price_nonnegative lemma
grep -i -A 8 "^### price_nonnegative$" coq-signatures.md | head -15

# Fetch bounded_loss_preserves_dwell_bound lemma
grep -i -A 8 "^### bounded_loss_preserves_dwell_bound$" coq-signatures.md | head -15
```

## Output Format

```
### price_nonnegative

Theorem price_nonnegative :

Proof.

  intros p d Hp.
```

## How It Works

1. **Search by header**: Matches markdown `###` headers with exact lemma name
2. **Show context**: `-A 8` displays 8 lines after match (theorem + proof start)
3. **Limit output**: `head -15` caps output to prevent overflow

## Token Efficiency

- ~200 tokens per lookup
- Alternative: searching full .v files (5k+ tokens)
- 96% reduction in lookup cost

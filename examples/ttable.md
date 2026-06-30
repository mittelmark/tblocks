---
mode: "ttable"
---

## Bonferroni

High Strictness

Multiplies p-values by the
number of tests.
Highly conservative.

Verdict: Prevents false
positives but washes out real,
small effects.
Many false negatives..

R: 
p.adjust(x,method="bonferroni")

## Holm Step-Down

Medium Strictness

Ranks p-values and applies
a decreasing multiplier
(n, n-1, n-2).

Verdict: A smarter, staged
alternative to Bonferroni.



R: 
p.adjust(x,method="holm")

## Benjamini-Hochberg (FDR)

Balanced Strictness

Controls the False Discovery
Rate by ranking larges to
smallest.

Verdict: The modern standard
for high-volume testing.
Balances discovery with 
caution.

R: 
p.adjust(x,method="BH")

---
mode: "compare"
---

## Inheritance (Is-A)

### Definition:

Class B is a proper subtype of
Class A (e.g., Dog is-a Animal).

### Diagnostic:

Both classes exist in the exact
same logical domain.

### Implementation:

Subclass enhancements are 
primarily additive.

## Composition (Has-A / Part-Of)

### Definition:

Class B embeds class A as a
component (e.g., Dog has-a Leg).

### Diagnostic:

You only need specific methods from base 
class, or wish to hide base class methods.

### Implementation:

Enables delegation of methods to
embedded components on the fly.

__Call by Value__
Concept:
    Clones the data.

`int add(int x, int y);`
`add(x,y);`

Safe but inefficient for large
data structures.

__Pointers__
Concept:
    Passes memory address.

`void swap(int *x, int *y);`
`swap(&x,&y);`

Requires eight '*' and two '&' symbols
for resolving the address issues.

__References__
Concept:
    Creates an alias.

`void swap(int &x, int &y);`
`swap(x,y);`

Requires only 4 '&' and only in the
argument lists. Clean function call.
References can't be reassigned.

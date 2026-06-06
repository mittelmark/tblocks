# tblocks

Tcl package to create presentation diagrams with block elements.

The basic idea is that we write our flowcharts with block diagrams in
Markdown. Here an example:

```md
## Call by Value
Concept:
    Clones the data.

`int add(int x, int y);`
`add(x,y);`

Safe but inefficient for large
data structures.

## Pointers
Concept:
    Passes memory address.

`void swap(int *x, int *y);`
`swap(&x,&y);`

Requires eight '*' and two '&' symbols
for resolving the address issues.

## References
Concept:
    Creates an alias.

`void swap(int &x, int &y);`
`swap(x,y);`

Requires only 4 '&' and only in the
argument lists. Clean function call.
References can't be reassigned.
```

After we call our program like this: `tclsh tblocks.tcl --blocks cpp-func.md cpp-func.svg`
we get the following output:

![](assets/cpp-func.svg)

## Installation

Copy the tblock.tcl file to a belonging to your PATH and make it executable.

Alternatively you can just download the single file Tcl-script https://raw.githubusercontent.com/mittelmark/tsvg/main/tsvg/tsvg.tcl and source it into your Tcl application.

## Changes

- 2026-06-05 development started with version 0.0.1

## License

BSD-3-Clause

## Author and Copyright

Detlef Groth, University of Potsdam, Germany

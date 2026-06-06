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

If you have four blocks, your tour blocks would be aligned as a 2x2 matrix. There are as well other type of block diagrams:

- tables - basically to big blocks side by side - see [examples/cpp-does.md](examples/cpp-does.md)
- sequences -  see [examples/sequence.md](examples/sequence.md)
- blocks - see [examples/cpp-overload.md](examples/cpp-overload.md)

To generate images out of these files see the commands in the [Makefile](Makefile).

Here an example for a sequence:

```md
## Title 1

- point 1
- point 2
- point 3


## Title 2 icon:yes

- point 4
- point 5
- point 6

## Title 3

* point 7
* point 8
* point 9


## Title 4

* point 10
* point 11
* point 12
```

And here the output after a call like this `tclsh tblocks.tcl sequence.md sequence.svg`.

![](assets/sequence.svg)

If you need pdf or png files as output you might use a tool like cairosvg to
convert the svg files to these other image formats. :

## Documentation

WIP

## Installation

Copy the [tblock.tcl](https://raw.githubusercontent.com/mittelmark/tblocks/main/tblocks/tblocks.tcl)
file to a belonging to your PATH and make it executable. You need to have the
Tcl programming language installed on your machine.

## TODO's

- flexible block height based on the number of input lines
- more block types
- more icons
- documentation

## Changes

- 2026-06-05 development started with version 0.0.1

## License

BSD-3-Clause

## Author and Copyright

Detlef Groth, University of Potsdam, Germany

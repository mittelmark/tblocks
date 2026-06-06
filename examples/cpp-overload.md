## Legacy C

Method: Macros


`#define dadd(x,y) ((x+y))`




Verdict: Evil, unsafe C-way.

## Explicit Overload

Method: Writing multiple functions

`int add(int x, int y);`

`float add(float x, fload y);`


Verdict: Tedious, hard to scale
   for more data types.
   
## C++98 Templates

Method: Generic Types

`template <typename T>`
`T add(T x, T y) { ... }`



Verdict: Clean, but problematic
  and complicated for mixing types.

## C++17 auto

Method: Compiler type deduction

`auto add (auto x, auto y) {`
`   return(x+y)`
`}`

Verdict: Ultimate flexibility.
  Requires consistent return types.





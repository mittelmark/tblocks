## DO icon:yes

- DO use references (&) instead of 
   pointers (*) for parameter lists.
  
- DO use const references when
   passing readonly objects.
  
- DO replace #define macros with
   inline functions or C++17 auto.
  
- DO convert recursive functions to
   iteration or memoization functions
   if speed becomes an issue.
  
- DO keep class variables private and
   build Getter and Setter gates to them.
  
- DO use initialization list for 
   const variables.
  
- DO use the algorithms of the Standard
   Template Library if appropiate.
   
## DON'T icon:no

- DON'T use pass by value for large
   data structures.
  
- DON'T default to C arrays, use 
   std::vector, std::array or std::map.
  
- DON'T work with C strings, use 
   std::string from the Standard
   Template Library (STL).
  
- DON'T leave class variables public
   unless writing simple structs.

- DON'T assume that like in Python 
   public inheritance is the default,  
   in C++ private inheritance is default.

%! stack.inc
%  a stack = [ array integer ]
%  the integer is the current stack size
%
%  <n> stack: returns anew stack of potential size n
%  <x> spush: pushes x onto the stack
%  spop: returns the current stack top
%  slength: returns current size
%  sempty: empty or not?
%  sextension: doubles the size
%  sarray: reurns an array of exactly the right size
%
%  no checks are made on arrays

/stackdict 8 dict def
stackdict begin

% n -> [[array of length n] 0]
/stack {
[ exch array 0 ]
} def

% x stack
/spush { % x s
aload % x a n s 
3 1 roll dup  % x s a n n
3 1 roll	% x s n a n
5 -1 roll      % s n a n x
put 		% s n
1 exch 1 add put
} def

% stack
/spop { % s
aload 3 1 roll	% s a n
1 sub dup 3 1 roll	% s n-1 a n-1
get	% s n-1 a[n-1]
3 1 roll  % a[n-1] s n-1
1 exch put
} def

% stack
/sempty {
1 get 0 eq
} def

% stack
/sfull {
aload pop exch length eq
} def

% stack
/slength {
1 get
} def

% stack -> doubled potential length
/sextension { 
aload 0 % a n s 0
4 2 roll pop % s 0 a 
[ exch % s 0 [ a 
aload length % s 0 [ ... ell
{ null } repeat ] % s 0 [...]
put 
} def

/sarray { % s
aload pop % a n
[ 3 1 roll	% [ a n 
exch aload length % [ n <ell> ell
dup 2 add -1 roll sub % % [ ... ell-n 
{ pop } repeat
]
} def

end

% -------------------------------------------------

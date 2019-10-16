% the new hodgman-sutherland algorithm
% returns an array of polygons, bounding the
% components of the truncation

(../../ps/stack.inc) run
(../../ps/sort.inc) run

/IN 0 def
/OUT 1 def
/NONE 2 def
/USED 4 def

/S 1 array def

% x y [A B C]
/evaluate2d { 
    aload pop  % x y A B C
    5 1 roll   % C x y A B
    3 2 roll   % C x A B y
    mul        % C x A By
    3 1 roll   % C By x A
    mul        % C By Ax
    add add 
} def

% polygon ell
/hs { stackdict begin
1 dict begin
/ell exch def
/p exch def
/n p length def
/P p n 1 sub get def
/fP P aload pop ell evaluate2d def

% s0 is the array of active points
% s1 holds category: IN/OUT/NONE
% s2 holds boundary points
/s0 n 3 mul stack def
/s1 n 3 mul stack def
/s2 n 3 mul stack def

p {
/Q exch def
/fQ Q aload pop ell evaluate2d def
  % [[[fP fQ]]] ==
fP 0 le {
  % fP <= 0
  fQ 0 le {
    % both in
  % (1) ==
    Q s0 spush 
    //NONE s1 spush
  }{ % fQ > 0
    % P in, Q out
  % (2) ==
    [
        P 0 get fQ mul 
        Q 0 get fP mul 
      sub 
      fQ fP sub div
        P 1 get fQ mul 
        Q 1 get fP mul 
      sub 
      fQ fP sub div
    ] 
    s0 spush
    //OUT s1 spush
    s0 slength 1 sub s2 spush
  } ifelse
}{
  % fP > 0
  fQ 0 le {   
    % Q in, P out
  % (3) ==
     [
        P 0 get fQ mul 
        Q 0 get fP mul 
      sub 
      fQ fP sub div
        P 1 get fQ mul 
        Q 1 get fP mul 
      sub 
      fQ fP sub div
    ]
    s0 spush
    //IN s1 spush
    s0 slength 1 sub s2 spush
    Q s0 spush
    //NONE s1 spush
  % }{ % fQ > 0 and fP > 0
    % both out
  % (4) ==
    % do nothing
  } if
} ifelse
/P Q def
/fP fQ def
} forall

% now to build the components
/S0 s0 sarray def
/S1 s1 sarray def
/S2 s2 sarray def

/n0 S0 length def
% S is  a global variable
S 0 S0 put 
% sort s2 according to the value of -Bx + Ay
/LT S2 quicksort 

% build S3 
/S3 n0 array def
0 1 S2 length 1 sub { /i exch def
  S3 S2 i get i put
} for

% -------------------------------------------------

[
  /count 0 def
  % count = number of points processed so far
  { % loop
    % (count = ) print count (   ) cvs print (\n) print

  count n0 ge { exit } if
  % set N = start = the first unused point in the path
  % there might not be any!  it might be a wholly interior path.
  /N 0 def
  {
    S1 N get //USED lt { exit } if
    /N N 1 add def
  } loop
  /start N def
  % N = index of current point in S
  [
  { % loop
    % (N = ) print N (   ) cvs print () =
    S0 N get % store S[N] on the operator stack
    /count count 1 add def
    % get type of S[N]
    % set t = type of currentpoint
    S1 N 2 copy % S1 N S1 N
    get % S1 N S1[N] 
    dup /t exch def %S1 N S1[N]
    % mark point N  used
    //USED add put
    % calculate next N
    % cases: current point = ingoing, outgoing, none
    t //IN eq {
      % (in) ==
      /N N 1 add def
      N S length eq { /N 0 def } if
    }{
      t //OUT eq {
      % (out) ==
      /m S3 N get def
  % (m = ) print m (   ) cvs print () =
      /m m 1 add def
      % m = index of S[N] next after in the boundary points
      m S2 length eq { /m 0 def } if 
      /N S2 m get def
    }{
      % (none) ==
      /N N 1 add def
      N S0 length eq { /N 0 def } if
    } ifelse
    } ifelse
    N start eq { exit } if
  } loop
  ] 
  } loop
]
end 
end } def

% i j
/LT { % i j
% S[0] is the array of points indexed by i, j
% ideally, S[0] would be passed as an argument
S 0 get dup % i j S[0] S[0]
4 1 roll % S[0] i j S[0]
exch get aload pop % S[0] i x[j] y[j]
ell 0 get mul exch ell 1 get mul sub % S[0] i ell[j]
3 1 roll get aload pop % ell[j] x[i] y[i]
ell 0 get mul exch ell 1 get mul sub % l[j] l[i]
gt
} def

% -----------------------------------------------------

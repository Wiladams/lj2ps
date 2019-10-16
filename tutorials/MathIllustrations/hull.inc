%!

(sort.inc) run

/hulldict 32 dict def

hulldict begin

% u - v 

/vsub { 2 dict begin
/v exch def
/u exch def
[ 
  u 0 get v 0 get sub
  u 1 get v 1 get sub
]
end } def

% u - v rotated 90 degrees

/vperp { 2 dict begin
/v exch def
/u exch def
[ 
  v 1 get u 1 get sub
  u 0 get v 0 get sub
]
end } def

/dot { 2 dict begin
/v exch def
/u exch def
  v 0 get u 0 get mul
  v 1 get u 1 get mul
  add
end } def 

% P Q
% tests whether P < Q in lexicographic order
% i.e xP < xQ, or yP < yQ if xP = yP

/comp { 2 dict begin
/Q exch def
/P exch def
P 0 get Q 0 get lt 
  P 0 get Q 0 get eq
  P 1 get Q 1 get lt 
  and 
or 
end } def

end

% args: an arrya of points C
% effect: returns the array of points on the boundary of
%     the convex hull of C, in clockwise order 

/hull { hulldict begin
/C exch def
/comp C quicksort
/n C length def
% Q might circle around to the start
/Q n 1 add array def
Q 0 C 0 get put
Q 1 C 1 get put
/i 2 def
/k 2 def
% i is next point in C to be looked at
% k is next point in Q to be added
% [ Q[0] Q[1] ... ]
% scan the points to make the top hull
n 2 sub {
  % P is the current point at right
  /P C i get def
  /i i 1 add def
  {
    % if k = 1 then just add P 
    k 2 lt { exit } if
    % now k is 2 or more
    % look at Q[k-2] Q[k-1] P: a left turn (or in a line)?
    % yes if (P - Q[k-1])*(Q[k-1] - Q[k-2])^perp >= 0
    P Q k 1 sub get vsub 
    Q k 1 sub get Q k 2 sub get vperp 
    dot 0 lt {
      % not a left turn
      exit
    } if
    /k k 1 sub def
  } loop
  Q k P put
  /k k 1 add def
} repeat

% done with top half
% K is where the right hand point is
/K k 1 sub def

/i n 2 sub def
Q k C i get put
/i i 1 sub def
/k k 1 add def
n 2 sub {
  % P is the current point at right
  /P C i get def
  /i i 1 sub def
  {
    % in this pass k is always 2 or more
    k K 2 add lt { exit } if
    % look at Q[k-2] Q[k-1] P: a left turn (or in a line)?
    % yes if (P - Q[k-1])*(Q[k-1] - Q[k-2])^perp >= 0
    P Q k 1 sub get vsub 
    Q k 1 sub get Q k 2 sub get vperp 
    dot 0 lt {
      % not a left turn
      exit
    } if
    /k k 1 sub def
  } loop
  Q k P put
  /k k 1 add def
} repeat

% strip Q down to [ Q[0] Q[1] ... Q[k-2] ]
% excluding the doubled initial point
[ 0 1 k 2 sub {
  Q exch get
} for ] 
end } def


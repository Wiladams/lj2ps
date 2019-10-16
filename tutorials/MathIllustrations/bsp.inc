
% bsp.inc
% * polygon-split
% * bsp-tree
% * traverse
% * polygon-interp
% * smooth-interp

% In these aroutines a vertex is an array of dimension d = 2 or 3
% whose first d items are the coordinates x y ...

/MaxInt 2.0 31 exp def

% N -> random mod N 
/random-mod { 4 dict begin
/N exch def
/R rand MaxInt div def
R N mul cvi
end } def

(ps3d.inc) run

/splitdict 10 dict def

splitdict begin

% x y ... [A B C ... ] = f => Ax + By + ... 

/evaluate2d { 
    aload pop  % x y A B C
    5 1 roll   % C x y A B
    3 2 roll   % C x A B y
    mul        % C x A By
    3 1 roll   % C By x A
    mul        % C By Ax
    add add 
} def

/evaluate3d {
    aload pop  % x y z A B C D
    7 1 roll   % D x y z A B C
    4 3 roll   % D x y A B C z
    mul        % D x y A B Cz 
    5 1 roll   % D Cz x y A B 
    3 2 roll   % D Cz x A B y
    mul        % D Cz x A By
    3 1 roll   % D Cz By x A
    mul        % D Cz By Ax
    add add add
} def


% - 0 + -> 0 1 2
/sign { 
dup 0 eq 
  {
    pop 1 
  }{
    0 gt {0}{2} ifelse
  } ifelse
} def

% requires d, P, Q, fP, fQ, plus, l+, minus, l-, negative, positive defined

/split [
% -- = 0
{ % fP < 0, fQ < 0 
  % push Q on minus
  minus l- Q put
  /l- l- 1 add def
  /negative true def
}
% -0 = 1
{ % fP < 0, fQ = 0 
  % push Q on plus, minus
  plus l+ Q put
  /l+ l+ 1 add def
  minus l- Q put
  /l- l- 1 add def
}
% -+ 2
{ % fP < 0, fQ > 0 
  % calculate the interpolation R = PQ cap ell
  /R P Q fQ fQ fP sub div interp def
  % push R on minus
  % push R, Q on plus
  minus l- R put
  /l- l- 1 add def
  plus l+ R put
  plus l+ 1 add Q put
  /l+ l+ 2 add def
  /positive true def
}
% 0- = 3
{ % P = 0, Q < 0
  % push Q on minus
  minus l- Q put
  /l- l- 1 add def
  /negative true def
}
% 00 = 4
{ % P = 0 = Q
  % push Q on both
  minus l- Q put
  /l- l- 1 add def
  plus l+ Q put
  /l+ l+ 1 add def
}
% 0+ = 5
{ % P = 0, Q > 0
  % push Q on plus
  plus l+ Q put
  /l+ l+ 1 add def
  /positive true def
}
% +- 6
{ % fP > 0, fQ < 0 
  % calculate the interpolation R = PQ cap ell
  % = f(P)Q - f(Q) P / f(P) - f(Q) 
  /R P Q fQ fQ fP sub div interp def
  % push R, Q on minus
  % push R on plus
  plus l+ R put
  /l+ l+ 1 add def
  minus l- R put
  minus l- 1 add Q put
  /l- l- 2 add def
  /negative true def
}
% +0 = 7
{ % fP > 0, fQ = 0 
  % push Q on plus, minus
  plus l+ Q put
  /l+ l+ 1 add def
  minus l- Q put
  /l- l- 1 add def
}
% ++ = 8
{ % fP > 0, fQ > 0 
  % push Q on plus
  plus l+ Q put
  /l+ l+ 1 add def
  /positive true def
}
] def

end

% polygon p = [[ ... ] ... [ ... ]] + splitting equation f + interpolation procedure
% the first part is an array of vertices
% and a vertex is an array [ x y ... ] where the first d items are coordinates
% returns: the thre arrays minus + zero + plus - respective intersections.
% zero is non-empty only if the others are blank - i.e. if the entire polygon
% happens to lie in f = 0.  This procedure is modeled on Hodgman-Sutherland.
% It would be nice to have a version that returns the actual outline
% that's chopped off - i.e. to start the vertex lists 
% with the crossing from - to + (plus) or + to - (minus), so it could be stroked

/polygon-split { load
splitdict begin
/interp exch def
/f exch def
/p exch def

% find the dimension involved
/d f length 1 sub def
d 2 eq {
  /e /evaluate2d load def
}{
  /e /evaluate3d load def
} ifelse

/n p length def
/plus n 2 mul array def
/l+ 0 def
/minus n 2 mul array def
/l- 0 def
/positive false def
/negative false def
% in the current scheme
% when we split we have to interpolate the normal

/P p n 1 sub get def
% this and the calculation of fQ
% are the only places where the dimension is referred to explicitly
/fP 0 1 d 1 sub {
  P exch get
} for 
f e def
/sP fP sign def
% now read p 
p {
  /Q exch def
  /fQ 0 1 d 1 sub {
    Q exch get
  } for 
  f e def
  /sQ fQ sign def

  split sP 3 mul sQ add get exec

  /P Q def
  /fP fQ def
  /sP sQ def
} forall

/minus [
  0 1 l- 1 sub {
    minus exch get
  } for
] def

/plus [
  0 1 l+ 1 sub {
    plus exch get
  } for
] def

positive {
  negative {
    % neither is empty
    minus
    []
    plus
  }{
    % plus not empty, minus empty
    []
    []
    plus
  } ifelse
}{
  negative {
    % plus is empty, minus not
    minus
    []
    []
  }{
    % contained in f=0, in which case minus=plus, both contain it
    []
    minus
    []
  } ifelse
} ifelse

end } def

% argument: an array of oriented polygonal faces [ p n s ... ]
% and a procedure to interpolate with
% returns: a tree, which is an array of 1 or 3 items
% the first item is always an array of oriented faces with the same normal function
% if 3 items, the last two are again trees, left and right
% BSP's therefore have a recursive structure

/bsp-tree { load 
8 dict begin
/interp exch def
/S exch def
/n S length def
n 1 eq {
  % we are looking at a leaf
  [ S ]
}{
  % we are looking at a branch
  /r n random-mod def
  /s S r get def
  /f s 1 get def
  % f now equals the normal function for a random face

  /left n 2 mul array def
  /L 0 def

  /middle n 2 mul array def
  middle 0 s put
  /M 1 def

  /right n 2 mul array def
  /R 0 def

  S {
    /face exch def
    /lf face length def
    /p face 0 get def
    /F face 1 get def
    F f eq {
      middle M face put
      /M M 1 add def
    }{
      % p = polygon, F = normal
      p f /interp polygon-split
      /plus exch def
      /zero exch def
      /minus exch def

      minus length 0 gt {
	    left L 
          [ minus 
            1 1 lf 1 sub { face exch get } for ]  
        put
        /L L 1 add def
	  } if

      zero length 0 gt {
		middle M 
          [ zero  
            1 1 lf 1 sub { face exch get } for ] 
        put
        /M M 1 add def
	  } if

      plus length 0 gt {
	    right R 
          [ plus  
            1 1 lf 1 sub { face exch get } for ]  
        put
        /R R 1 add def
      } if
	} ifelse
  } forall
  % now left, middle, and right are built: shrink wrap them
  /left [
    0 1 L 1 sub {
      left exch get
	} for
  ] def

  /middle [
    0 1 M 1 sub {
      middle exch get
	} for
  ] def

  /right [
    0 1 R 1 sub {
      right exch get
	} for
  ] def

  L 0 eq R 0 eq and {
    [ middle ]
  }{ 
    [
      middle
      left length 0 gt { left /interp bsp-tree }{ [] } ifelse
      right length 0 gt { right /interp bsp-tree }{ [] } ifelse
      % HAVE TO FIX RECURSION
    ]
  } ifelse
} ifelse
end 

} def

% arguments: a bsp-tree and a procedure 
% the procedure is applied to each face
% E is a global variable: relative position of the eye
/traverse { load
1 dict begin
/f exch def
/T exch def
/stack 4092 array def
stack 0 T put
/h 1 def
{
  h 1 lt {
    exit
  } if
  /h h 1 sub def
  /T stack h get def
  T length 1 le {
    T length 1 eq {
      % T is a leaf
      T 0 get       
      {
        % T[0] = [p n sign]
        f
      } forall
    } if
  }{
    % T is a branch
    T 0 get 0 get 1 get     % normal function
    % decide which side of T the eye is
    E dot-product 0 
    le {
      stack h       T 2 get put
      stack h 1 add [ T 0 get ] put
      stack h 2 add T 1 get put
      /h h 3 add def
    }{
      stack h       T 1 get put
      stack h 1 add [ T 0 get ] put
      stack h 2 add T 2 get put
      /h h 3 add def
    } ifelse
  } ifelse
} loop
end } def

% P Q t
/polygon-interp { 1 dict begin
  /t exch def
  /s 1 t sub def
  /Q exch def
  /P exch def
  [
    P 0 get t mul Q 0 get s mul add
    P 1 get t mul Q 1 get s mul add
    P 2 get t mul Q 2 get s mul add
  ]
end } def

% P Q t
/smooth-interp { 1 dict begin
  /t exch def
  /s 1 t sub def
  /Q exch def
  /P exch def
  /nP P 3 get def
  /nQ Q 3 get def
  [
    P 0 get t mul Q 0 get s mul add
    P 1 get t mul Q 1 get s mul add
    P 2 get t mul Q 2 get s mul add
    [ 
      nP 0 get t mul nQ 0 get s mul add
      nP 1 get t mul nQ 1 get s mul add
      nP 2 get t mul nQ 2 get s mul add
      nP 3 get t mul nQ 3 get s mul add
    ] 
  ]
end } def


% Follows Euclid's construction of the regular polyhedra

/cube-vertex [
[-1 -1 -1]
[-1 1 -1]
[1 1 -1]
[1 -1 -1]
[-1 -1 1]
[-1 1 1]
[1 1 1]
[1 -1 1]
] def

/cube-face [
[
  cube-vertex 0 get
  cube-vertex 1 get
  cube-vertex 2 get
  cube-vertex 3 get
] 
[
  cube-vertex 4 get
  cube-vertex 7 get
  cube-vertex 6 get
  cube-vertex 5 get
] 
[
  cube-vertex 0 get
  cube-vertex 4 get
  cube-vertex 5 get
  cube-vertex 1 get
] 
[
  cube-vertex 6 get
  cube-vertex 7 get
  cube-vertex 3 get
  cube-vertex 2 get
] 
[
  cube-vertex 2 get
  cube-vertex 1 get
  cube-vertex 5 get
  cube-vertex 6 get
] 
[
  cube-vertex 0 get
  cube-vertex 3 get
  cube-vertex 7 get
  cube-vertex 4 get
] 
] def

/cube [
8 dict begin
cube-face {
  % a face = an array normal plus vertex array
  [
    exch
    /f exch def 
    f 1 get f 0 get vector-sub
    f 2 get f 1 get vector-sub
    cross-product normalized /n exch def
    [ n aload pop
    n f 0 get dot-product neg ]
    f
  ]
} forall
end
] def

/tetrahedron-vertex [
  cube-vertex 0 get
  cube-vertex 2 get
  cube-vertex 5 get
  cube-vertex 7 get
] def

/tetrahedron-face [
[
  tetrahedron-vertex 0 get 
  tetrahedron-vertex 1 get 
  tetrahedron-vertex 3 get 
]
[
  tetrahedron-vertex 0 get 
  tetrahedron-vertex 2 get 
  tetrahedron-vertex 1 get 
]
[
  tetrahedron-vertex 0 get 
  tetrahedron-vertex 3 get 
  tetrahedron-vertex 2 get 
]
[
  tetrahedron-vertex 1 get 
  tetrahedron-vertex 2 get 
  tetrahedron-vertex 3 get 
]
] def

/tetrahedron [
8 dict begin
tetrahedron-face {
  % a face = an array normal plus vertex array
  [
    exch
    /f exch def 
    f 1 get f 0 get vector-sub
    f 2 get f 1 get vector-sub
    cross-product normalized /n exch def
    [ n aload pop
    n f 0 get dot-product neg ]
    f
  ]
} forall
end
] def

% a list of vertices

/centre {
5 dict begin
dup length /n exch def
/cx 0 def
/cy 0 def
/cz 0 def
{
  /f exch def
  /cx cx f 0 get add def
  /cy cy f 0 get add def
  /cz cz f 0 get add def
} forall
[cx n div cy n div cz n div]
end
} def

/octahedron-vertex [
[0 0 1]
[0 1 0]
[1 0 0]
[0 0 -1]
[0 -1 0]
[-1 0 0]
] def

/octahedron-face [
[
  octahedron-vertex 0 get
  octahedron-vertex 5 get
  octahedron-vertex 4 get
]
[
  octahedron-vertex 0 get
  octahedron-vertex 4 get
  octahedron-vertex 2 get
]
[
  octahedron-vertex 0 get
  octahedron-vertex 2 get
  octahedron-vertex 1 get
]
[
  octahedron-vertex 0 get
  octahedron-vertex 1 get
  octahedron-vertex 5 get
]
[
  octahedron-vertex 3 get
  octahedron-vertex 4 get
  octahedron-vertex 5 get
]
[
  octahedron-vertex 3 get
  octahedron-vertex 2 get
  octahedron-vertex 4 get
]
[
  octahedron-vertex 3 get
  octahedron-vertex 1 get
  octahedron-vertex 2 get
]
[
  octahedron-vertex 3 get
  octahedron-vertex 5 get
  octahedron-vertex 1 get
]
] def

/octahedron [
8 dict begin
octahedron-face {
  % a face = an array normal plus vertex array
  [
    exch
    /f exch def 
    f 1 get f 0 get vector-sub
    f 2 get f 1 get vector-sub
    cross-product normalized /n exch def
    [ n aload pop
    n f 0 get dot-product neg ]
    f
  ]
} forall
end
] def


/icosahedron-vertex [
4 dict begin
  % d = length of an edge
  /y 5 sqrt 1 5 sqrt add div def
  /d 2 sqrt y sqrt mul def
  % make other edges of the same length
  /h d dup mul 1 36 cos sub dup mul sub 36 sin dup mul sub sqrt 2 div def
  /g d dup mul 1 sub sqrt h add def
  [0 0 g]
  
  [1 0 h]
  [72 cos 72 sin h]
  [144 cos 144 sin h]
  [216 cos 216 sin h]
  [288 cos 288 sin h]
  
  [-36 cos -36 sin h neg]
  [-108 cos -108 sin h neg]
  [-1 0 h neg]
  [108 cos 108 sin h neg]
  [ 36 cos  36 sin h neg]
  
  [0 0 g neg]
end
] 
def

/icosahedron-face [
8 dict begin
  [ 
    icosahedron-vertex 0 get 
    icosahedron-vertex 1 get 
    icosahedron-vertex 2 get 
  ]
  [ 
    icosahedron-vertex 0 get 
    icosahedron-vertex 2 get 
    icosahedron-vertex 3 get 
  ]
  [ 
    icosahedron-vertex 0 get 
    icosahedron-vertex 3 get 
    icosahedron-vertex 4 get 
  ]
  [ 
    icosahedron-vertex 0 get 
    icosahedron-vertex 4 get 
    icosahedron-vertex 5 get 
  ]
  [ 
    icosahedron-vertex 0 get 
    icosahedron-vertex 5 get 
    icosahedron-vertex 1 get 
  ]
  
  % ----------------------------

  [
    icosahedron-vertex 2 get 
    icosahedron-vertex 1 get 
    icosahedron-vertex 10 get 
  ]
  [
    icosahedron-vertex 2 get 
    icosahedron-vertex 10 get 
    icosahedron-vertex 9 get 
  ]
  [
    icosahedron-vertex 3 get 
    icosahedron-vertex 2 get 
    icosahedron-vertex 9 get 
  ]
  [
    icosahedron-vertex 3 get 
    icosahedron-vertex 9 get 
    icosahedron-vertex 8 get 
  ]
  [
    icosahedron-vertex 4 get 
    icosahedron-vertex 3 get 
    icosahedron-vertex 8 get 
  ]
  [
    icosahedron-vertex 4 get 
    icosahedron-vertex 8 get 
    icosahedron-vertex 7 get 
  ]
  [
    icosahedron-vertex 5 get 
    icosahedron-vertex 4 get 
    icosahedron-vertex 7 get 
  ]
  [
    icosahedron-vertex 5 get 
    icosahedron-vertex 7 get 
    icosahedron-vertex 6 get 
  ]
  [
    icosahedron-vertex 1 get 
    icosahedron-vertex 5 get 
    icosahedron-vertex 6 get 
  ]
  [
    icosahedron-vertex 1 get 
    icosahedron-vertex 6 get 
    icosahedron-vertex 10 get 
  ]

  % ----------------------------

  [ 
    icosahedron-vertex 6 get 
    icosahedron-vertex 7 get 
    icosahedron-vertex 11 get 
  ]
  [ 
    icosahedron-vertex 7 get 
    icosahedron-vertex 8 get 
    icosahedron-vertex 11 get 
  ]
  [ 
    icosahedron-vertex 8 get 
    icosahedron-vertex 9 get 
    icosahedron-vertex 11 get 
  ]
  [ 
    icosahedron-vertex 9 get 
    icosahedron-vertex 10 get 
    icosahedron-vertex 11 get 
  ]
  [ 
    icosahedron-vertex 10 get 
    icosahedron-vertex 6 get 
    icosahedron-vertex 11 get 
  ]
end
] def

/icosahedron [
8 dict begin
icosahedron-face {
  % a face = an array normal plus vertex array
  [
    exch
    /f exch def 
    f 1 get f 0 get vector-sub
    f 2 get f 1 get vector-sub
    cross-product normalized /n exch def
    [ n aload pop
    n f 0 get dot-product neg ]
    f
  ]
} forall
end
] def

/dodecahedron-vertex [
8 dict begin
% the vertex is located at (x, y, z) on a cube face
% z = vertical displacement from cube face
% d/s = (1 + sqrt(5))/2
  /d 2 def
  /s d 1 5 sqrt add div 2 mul def
  /y s 0.5 mul def
  /z 
    s dup mul 
    1 
    sub 
    1 y sub dup mul  
    sub 
  sqrt 
  def
  
  cube-vertex 0 get 
  cube-vertex 1 get 
  cube-vertex 2 get 
  cube-vertex 3 get 
  cube-vertex 4 get 
  cube-vertex 5 get 
  cube-vertex 6 get 
  cube-vertex 7 get
    
  [0 1 z add y]
  [0 1 z add y neg]
  [0 -1 z sub y]
  [0 -1 z sub y neg]

  [y 0 1 z add]
  [y neg 0 1 z add]
  [y 0 -1 z sub]
  [y neg 0 -1 z sub]

  [1 z add y 0]
  [1 z add y neg 0]
  [-1 z sub y 0]
  [-1 z sub y neg 0]
end
] def

/dodecahedron-face [
  [
    dodecahedron-vertex 0 get
    dodecahedron-vertex 11 get
    dodecahedron-vertex 10 get
    dodecahedron-vertex 4 get
    dodecahedron-vertex 19 get
  ]
  [
    dodecahedron-vertex 11 get
    dodecahedron-vertex 3 get
    dodecahedron-vertex 17 get
    dodecahedron-vertex 7 get
    dodecahedron-vertex 10 get
  ]
  % --------------------------
  [
    dodecahedron-vertex 13 get
    dodecahedron-vertex 12 get
    dodecahedron-vertex 6 get
    dodecahedron-vertex 8 get
    dodecahedron-vertex 5 get
  ]
  [
    dodecahedron-vertex 10 get
    dodecahedron-vertex 7 get
    dodecahedron-vertex 12 get
    dodecahedron-vertex 13 get
    dodecahedron-vertex 4 get
  ]
  % --------------------------
  [
    dodecahedron-vertex 16 get
    dodecahedron-vertex 17 get
    dodecahedron-vertex 3 get
    dodecahedron-vertex 14 get
    dodecahedron-vertex 2 get
  ]
  [
    dodecahedron-vertex 17 get
    dodecahedron-vertex 16 get
    dodecahedron-vertex 6 get
    dodecahedron-vertex 12 get
    dodecahedron-vertex 7 get
  ]
  % --------------------------
  [
    dodecahedron-vertex 18 get
    dodecahedron-vertex 19 get
    dodecahedron-vertex 4 get
    dodecahedron-vertex 13 get
    dodecahedron-vertex 5 get
  ]
  [
    dodecahedron-vertex 19 get
    dodecahedron-vertex 18 get
    dodecahedron-vertex 1 get
    dodecahedron-vertex 15 get
    dodecahedron-vertex 0 get
  ]
  % --------------------------
  [
    dodecahedron-vertex 15 get
    dodecahedron-vertex 14 get
    dodecahedron-vertex 3 get
    dodecahedron-vertex 11 get
    dodecahedron-vertex 0 get
  ]
  [
    dodecahedron-vertex 14 get
    dodecahedron-vertex 15 get
    dodecahedron-vertex 1 get
    dodecahedron-vertex 9 get
    dodecahedron-vertex 2 get
  ]
  % --------------------------
  [
    dodecahedron-vertex 8 get
    dodecahedron-vertex 9 get
    dodecahedron-vertex 1 get
    dodecahedron-vertex 18 get
    dodecahedron-vertex 5 get
  ]
  [
    dodecahedron-vertex 9 get
    dodecahedron-vertex 8 get
    dodecahedron-vertex 6 get
    dodecahedron-vertex 16 get
    dodecahedron-vertex 2 get
  ]

] def

/dodecahedron [
8 dict begin
dodecahedron-face {
  % a face = an array normal plus vertex array
  [
    exch
    /f exch def 
    f 1 get f 0 get vector-sub
    f 2 get f 1 get vector-sub
    cross-product normalized /n exch def
    [ n aload pop
    n f 0 get dot-product neg ]
    f
  ]
} forall
end
] def


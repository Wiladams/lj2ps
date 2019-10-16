% reads an arbitrary path and makes all commands current

/open {
[
  { % x y
    [ 3 1 roll {moveto}]
    
  }
  { % x y
    [ 3 1 roll {lineto}]
  }
  { % x1 y1 x2 y2 x3 y3
    [ 7 1 roll
    {curveto} ]
  }
  {
    [ {closepath} ]
  }
  pathforall
]
newpath
{
  aload pop exec
} forall
} def

% replaces the current path by a subdivided path
% moveto, closepath: no difference
% line segments are turned to Bezier curves,
% Bezier curves are bisected

/subdivide { 16 dict begin
[
  { % x y (moveto)
	/cy exch def
	/cx exch def
	/lx cx def
	/ly cy def
    [ cx cy {moveto}]
  }
  { % x y (lineto)
	/Y exch def
	/X exch def
    [ 
		0.66667 cx mul 0.33333 X mul add 
		0.66667 cy mul 0.33333 Y mul add 
		0.33333 cx mul 0.66667 X mul add 
		0.33333 cy mul 0.66667 Y mul add 
		X Y 
		/cx X def
		/cy Y def
		{curveto}
	]
	/cx X def
	/cy Y def
  }
  { % x1 y1 x2 y2 x3 y3
	/y3 exch def /x3 exch def
	/y2 exch def /x2 exch def
	/y1 exch def /x1 exch def
	/x01 cx x1 add 0.5 mul def
	/y01 cy y1 add 0.5 mul def
	/x12 x1 x2 add 0.5 mul def
	/y12 y1 y2 add 0.5 mul def
	/x23 x2 x3 add 0.5 mul def
	/y23 y2 y3 add 0.5 mul def
	/x012 x01 x12 add 0.5 mul def
	/y012 y01 y12 add 0.5 mul def
	/x123 x12 x23 add 0.5 mul def
	/y123 y12 y23 add 0.5 mul def
	
	[ x01 y01
      x012 y012
	    x012 x123 add 0.5 mul
	    y012 y123 add 0.5 mul
      {curveto} 
	]
	[ x123 y123
	  x23 y23
	  x3 y3
      {curveto} 
	]
	/cx x3 def /cy y3 def
  }
  {
    [ {closepath} ]
	/cx lx def
	/cy ly def
  }
  pathforall
]
newpath
{
  aload pop exec
} forall
end } def

% replaces the current path by a transformed path
% the transformation is applied to control points
% pars /f on stack
% f: x y pars -> u v
% c = coarse

/ctransform { load 
8 dict begin
/f exch def
/pars exch def
[
  { % x y (moveto)
	2 copy /cy exch def /cx exch def
    [ 3 1 roll pars f {moveto}]
	/lx cx def
	/ly cy def
  }
  { % x y (lineto)
	2 copy /cy exch def /cx exch def
	[ 3 1 roll pars f {lineto} ]
  }
  { % x1 y1 x2 y2 x3 y3
	2 copy /cy exch def /cx exch def
	[ 7 1 roll			% [ P1 P2 P3
	  pars f			% [ P1 P2 U3
	  6 2 roll pars f	% [ U3 P1 U2
	  6 2 roll pars f	% [ U2 U3 U1 
	  6 2 roll % [ U1 U2 U3
      {curveto} 
	]
  }
  {
    [ {closepath} ]
	/cx lx def
	/cy ly def
  }
  pathforall
]
newpath
{
  aload pop exec
} forall
end } def

% -------------------------------------------------

% In this version, f returns u v [fxx fxy fyx fyy] 
% f: x y pars -> u v [ .... ]
% f = fine

/ftransform { load 
8 dict begin
/f exch def
/pars exch def
[
  { % x y (moveto)
	2 copy /cy exch def /cx exch def
	pars f 
	/jac exch def 
	/cv exch def
	/cu exch def
	[cu cv {moveto}]
	/lx cx def
	/ly cy def
  }
  { % x y (lineto)
	2 copy /cy exch def /cx exch def
	pars f 
	/jac exch def 
	/cv exch def
	/cu exch def
	[cu cv {lineto}]
  }
  { % x1 y1 x2 y2 x3 y3
	% [ f(cP) + Jac_0*[P1-cP] f(P3) - Jac_{1}*(P3-P2) f(P3)
	  /y3 exch def
	  /x3 exch def
	  /y2 exch def
	  /x2 exch def
	  /y1 exch def
	  /x1 exch def
	  [ 
	  /dx x1 cx sub def
	  /dy y1 cy sub def
	  jac 0 get dx mul jac 1 get dy mul add cu add	% u1
	  jac 2 get dx mul jac 3 get dy mul add cv add	% v1
	  /cx x3 def /cy y3 def
	  /dx x2 x3 sub def
	  /dy y2 y3 sub def
	  cx cy pars f /jac exch def
	  /cv exch def /cu exch def
	  jac 0 get dx mul jac 1 get dy mul add cu add	% u2
	  jac 2 get dx mul jac 3 get dy mul add cv add	% v2
	  cu cv % u3 v3
      {curveto} 
	]
  }
  {
    [ {closepath} ]
	/cx lx def
	/cy ly def
	cx cy pars f
	/jac exch def
	/cv exch def
	/cu exch def
  }
  pathforall
]
newpath
{
  aload pop exec
} forall
end } def

% ----------------------------------------------------




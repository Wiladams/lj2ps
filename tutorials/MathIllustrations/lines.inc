%! --- lines.inc -------------------------------

% Two routines: 
% segment-page: [A B C] -> P Q
%   where in page coordinates PQ contains the visible part of the line
%   Ax + By + C = 0 
% mkline: [A B C] -> builds visible part of line Ax + By + C = 0

% ----------------------------------------------

/linesdict 8 dict def

linesdict begin

/segment-page {
pstack
8 dict begin
aload pop
/C exch def
/B exch def
/A exch def

A abs B abs le
{
  /xleft 0 def
  /xright 612 def
  /yleft C A xleft mul add B div neg def
  % y = -C - Ax / B
  /yright C A xright mul add B div neg def
  [xleft yleft]
  [xright yright]
}{
  /ybottom 0 def
  /ytop 792 def
  /xbottom C B ybottom mul add A div neg def
  % y = -C - Ax / B
  /xtop C B ytop mul add A div neg def
  [xbottom ybottom]
  [xtop ytop]
} ifelse
end
} def

end

/mkline { 8 dict begin
  aload pop
  /C exch def
  /B exch def
  /A exch def
  /T 
    matrix defaultmatrix
    matrix currentmatrix
    matrix invertmatrix 
    matrix concatmatrix 
  def
  [ 
	A T 0 get mul 
	B T 1 get mul add

	A T 2 get mul 
	B T 3 get mul add

	T 4 get A mul
	T 5 get B mul add
	C add
  ] 
  linesdict begin
	segment-page
  end

  aload pop T transform moveto
  aload pop T transform lineto
end } def

% -------------------------------------------------------

% = zoom.inc ===============================================

% assuming an 8.5 x 11 page

/page-centre {
[
4.25 72 mul 5.5 72 mul 
matrix defaultmatrix transform
matrix currentmatrix itransform
]
} def

% x y

/page-to-user-transform {
	matrix defaultmatrix transform
    matrix currentmatrix itransform
} def

/user-to-page-transform {
	matrix currentmatrix transform
    matrix defaultmatrix itransform
} def

% [cx cy] [x y] s: the place that is now (x, y) is located at (cx, cy)
% and lengths scaled by s

/zoom {
8 dict begin
/s exch def
aload pop
/y exch def
/x exch def
aload pop
translate
s dup scale
x neg y neg translate
currentlinewidth s div setlinewidth
end
} def

% [cx cy] [x y] 4-array T: the place that is now (x, y) is located at (cx, cy)
% local transformation = T

/Zoom {
8 dict begin
/T exch def
aload pop
/y exch def
/x exch def
aload pop
translate
[ T aload pop 0 0 ] concat 
x neg y neg translate
end
} def

% - zoom.inc ------------------------------------------------



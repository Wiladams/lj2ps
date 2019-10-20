%!PS-Adobe-3.0 EPSF-3.0
%%BeginProlog
/u 16 def           % 16 points per unit
/lw 1 u div def     % default line width
/Times-Roman findfont 8 u div scalefont setfont
/display {
    dup 
    3 1 roll 
    10 exch exp mul round
    10 3 -1 roll
    exp div
} def

/str 10 string def
/n 10 def
/dp 2 def           % display precision
%%EndProlog


u dup scale 
lw setlinewidth
1.8 1.8 translate
%
0 1 n {
    /i exch def
    % draw horizontal labels
    i 0.1 add -0.75 moveto 
    i n div dp display str cvs show 

    %draw vertical labels
    -1 i 0.25 add moveto 
    i n div dp display str cvs show
    0 1 n {
        /j exch def
        gsave
            i n div j n div 0 setrgbcolor
            newpath i j 1 1 rectfill
            0 setgray
            newpath i j 1 1 rectstroke
        grestore
    } for
} for
n 2 div -1.5 moveto (r) show
-1.5 n 2 div moveto (g) show
n 2 div 1 sub n 1.5 add moveto
(RGB[r, g, 0]) show
showpage
%%EOF

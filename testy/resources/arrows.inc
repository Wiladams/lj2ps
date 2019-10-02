
/cot { dup cos exch sin div } def

% arrowlength shaftwidth headwidth A B
% A B are angles at point, back of head 

/arrow {
12 dict begin
/B exch def
/A exch def
/headwidth exch def
/shaftwidth exch def
/w shaftwidth 0.5 mul def
/arrowlength exch def

/x headwidth 2 div A cot mul def
/y headwidth 2 div B cot mul def
/z shaftwidth 2 div B cot mul def

/shaftlength arrowlength x sub y add z sub def

currentlinecap 0 eq {
0 w neg moveto
0 w lineto
shaftlength w lineto
arrowlength x sub headwidth 0.5 mul lineto
arrowlength 0 lineto
arrowlength x sub headwidth -0.5 mul lineto
shaftlength w neg lineto
closepath
} if

currentlinecap 1 eq {
0 w neg moveto
0 0 w -90 90 arcn
shaftlength w lineto
arrowlength x sub headwidth 0.5 mul lineto
arrowlength 0 lineto
arrowlength x sub headwidth -0.5 mul lineto
shaftlength w neg lineto
closepath
} if

currentlinecap 2 eq {
w neg 0 moveto
w neg w lineto
shaftlength w lineto
arrowlength x sub headwidth 0.5 mul lineto
arrowlength 0 lineto
arrowlength x sub headwidth -0.5 mul lineto
shaftlength w neg lineto
w neg w neg lineto
closepath
} if

end
} def

% A = 24, B = 60 are good

% x y shaft-width head-width A B

/mkarrow {
12 dict begin
/B exch def
/A exch def
/headwidth exch def
/shaftwidth exch def
/y exch def
/x exch def
/C y x atan def
C rotate
/r x dup mul y dup mul add sqrt def
r shaftwidth headwidth A B arrow
C neg rotate
end } def

% draws along a Bezier curve
% P0 P1 P2 P3 sw hw A B

/fillcurvedarrow { 16 dict begin
gsave
/B exch def
/A exch def
/hw exch def
/sw exch def
/P3 exch def
/P2 exch def
/P1 exch def
/P0 exch def
newpath
sw setlinewidth
P1 0 get P0 0 get sub P1 1 get P0 1 get sub vlength /L exch def
P0 0 get P0 1 get moveto
P1 aload pop
P2 aload pop 
P3 0 get P2 0 get sub P3 1 get P2 1 get sub vlength /L exch def
P3 0 get P2 0 get sub hw L div mul /dx exch def
P3 1 get P2 1 get sub hw L div mul /dy exch def
P3 0 get dx sub P3 1 get dy sub
curveto
stroke
newpath
P3 aload pop translate
dx neg dy neg translate
P3 1 get P2 1 get sub
P3 0 get P2 0 get sub 
atan rotate
hw sw hw A B arrow
fill
grestore
end } def



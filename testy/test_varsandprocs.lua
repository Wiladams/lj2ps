package.path = "../?.lua;"..package.path

local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")


local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

interp:run([[
% Variables and Procedures ---------
/scalefactor 1 def
/counter 0 def
/DecreaseScale {
    scalefactor 0.2 sub
    /scalefactor exch def 
} def

/IncreaseCounter {
    /counter counter 1 add def
} def

/trappath  %construct a trapezoid
{
    0 0 moveto 
    90 0 rlineto
    -20 45 rlineto
    -50 0 rlineto
    closepath
} def

/doATrap
{
    gsave
     1 scalefactor scale
     trappath
     counter 2 mod
     0 eq {0.5} {0} ifelse
     setgray fill
    grestore
} def

% ---- Begin Program ----
250 350 translate

5
{IncreaseCounter
doATrap
DecreaseScale
0 20 translate} repeat

showpage
]])
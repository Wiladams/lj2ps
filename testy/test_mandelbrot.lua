package.path = "../?.lua;"..package.path

--[[
http://paulbourke.net/dataformats/postscript/
--]]


local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")

local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

local script = [[
%!PS-Adobe-2.0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                       %
%   Mandelbrot set via PostScript code. Not optimized   %
%   in any way. Centered in A4 paper. Escape time, B&W  %
%                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/fun {
    4 3 roll 		% y c1 c2 x
    dup dup		% y c1 c2 x x x
    mul 		% y c1 c2 x x^2
    5 4 roll		% c1 c2 x x^2 y
    dup dup mul		% c1 c2 x x^2 y y^2
    2 index exch sub	% c1 c2 x x^2 y (x^2-y^2)
    6 1 roll 2 index  	% (x^2-y^2) c1 c2 x x^2 y x
    2 mul mul		% (x^2-y^2) c1 c2 x x^2 2xy
    6 1 roll		% 2xy (x^2-y^2) c1 c2 x x^2
    pop pop 4 1 roll	% c2 2xy (x^2-y^2) c1
    dup 5 1 roll add	% c1 c2 2xy (x^2-y^2+c1)
    4 1 roll		% (x^2-y^2+c1) c1 c2 2xy
    1 index		% (x^2-y^2+c1) c1 c2 2xy c2
    add	4 3 roll	% c1 c2 (2xy+c2) (x^2-y^2+c1)
    exch 4 2 roll	% (x^2-y^2+c1) (2xy+c2) c1 c2
} def

/res 500 def 
/iter 50 def


300 300 translate
90 rotate
-150 -260 translate
0 1 res {
    /x exch def
    0 1 res {
	/y exch def 
	    0 0
	    -2.5 4 x mul res div add
	    2 4 y mul res div sub
	    iter -1 0  {
		/n exch store
		fun
		2 index dup mul
		4 index dup mul
		add sqrt
		4 gt
		{exit} if
	    } for
	    pop pop pop pop


	    n 0 gt
	    {1 setgray
		x y 0.7 0 360 arc
		fill
	    }
	    {
		0 setgray
		x y 0.5 0 360 arc
		fill
	    } ifelse
	    } for
	}for
showpage
]]

interp:run(script)
		
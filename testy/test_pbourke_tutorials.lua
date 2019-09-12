package.path = "../?.lua;"..package.path

--[[
http://paulbourke.net/dataformats/postscript/
--]]


local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")

local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

local function test_example1()
    interp:run([[
%!
%% Example 1

newpath
100 200 moveto
200 250 lineto
100 300 lineto
closepath
2 setlinewidth
stroke
showpage
]])
end

local function test_example2()
    interp:run([[
%!
%% Example 2

newpath
100 200 moveto
200 250 lineto
100 300 lineto
closepath
gsave
0.5 setgray
fill
grestore
4 setlinewidth
0.75 setgray
stroke
showpage
]])
end

local function test_example5()
    interp:run([[
%!
%% Example 5

newpath
100 100 moveto
0 100 rlineto
100 0 rlineto
0 -100 rlineto
-100 0 rlineto
closepath
gsave
0.5 1 0.5 setrgbcolor
fill
grestore
1 0 0 setrgbcolor
4 setlinewidth
stroke
showpage
]])
end

local function test_example6()
interp:run([[
/csquare {
    newpath
    0 0 moveto
    0 1 rlineto
    1 0 rlineto
    0 -1 rlineto
    closepath
    setrgbcolor
    fill
} def

20 20 scale

5 5 translate
1 0 0 csquare

1 0 translate
0 1 0 csquare

1 0 translate
0 0 1 csquare
showpage
]])
end

--[[
    For this example, the paulbourke website has the vertical 
    order reversed.  The y-coordinates start at the top
    That, or the enum values for the caps are wrong
]]
local function test_example7()
interp:run([[
/LINE {
  newpath
  0 0 moveto
  100 0 lineto
  stroke
} def

100 200 translate
10 setlinewidth 0 setlinecap 0 setgray LINE
1 setlinewidth 1 setgray LINE

0 20 translate
10 setlinewidth 1 setlinecap 0 setgray LINE
1 setlinewidth 1 setgray LINE

0 20 translate
10 setlinewidth 2 setlinecap 0 setgray LINE
1 setlinewidth 1 setgray LINE

showpage
]])
end

-- setlinejoin
local function test_example8()
interp:run([[
/ANGLE {
    newpath
    100 0 moveto
    0 0 lineto
    100 50 lineto
    stroke
} def

10 setlinewidth
0 setlinejoin
100 200 translate
ANGLE

1 setlinejoin
0 70 translate
ANGLE

2 setlinejoin
0 70 translate
ANGLE

showpage
]])
end


--test_example1()
--test_example2()
--test_example5()
--test_example6()
--test_example7()
test_example8()


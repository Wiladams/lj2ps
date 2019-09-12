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

--test_example1()
--test_example2()
test_example5()
